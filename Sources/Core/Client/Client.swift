//
//  Client.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import UIKit
import Moya

typealias ClientCompletionResult = Result<Moya.Response, ClientError>
typealias ClientCompletion = (_ result: ClientCompletionResult) -> Void
typealias NetworkProvider = MoyaProvider<MultiTarget>

/// GetStream client.
public final class Client {
    let apiKey: String
    let appId: String
    let baseURL: BaseURL
    let callbackQueue: DispatchQueue
    let workingQueue: DispatchQueue
    
    var token: Token = "" {
        didSet {
            networkAuthorization.token = token
        }
    }
    
    private let networkProvider: NetworkProvider
    private let networkAuthorization: AuthorizationMoyaPlugin
    private var consecutiveFailures = 0
    let logger: ClientLogger?
    
    /// The current user id from the Token.
    public internal(set) var currentUserId: String?
    /// The current user.
    public internal(set) var currentUser: UserProtocol?
    
    /// A configuration to initialize the shared Client.
    public static var config = Config(apiKey: "", appId: "")
    
    /// Enable this if you want to wrap any `Missable` bad decoded objects as missed.
    /// - Note: If it's enabled the parser will return a response with missed objects and print errors in logs.
    public static var keepBadDecodedObjectsAsMissed = false
    
    /// A shared client.
    /// - Note: Setup `Client.config` before using a shared client.
    /// ```
    /// // Setup a shared client.
    /// Client.config = .init(apiKey: "API_KEY", appId: "APP_ID", token: "TOKEN")
    ///
    /// // Create Chris's user feed.
    /// let chrisFeed = Client.shared.flatFeed(feedSlug: "user", userId: "chris")
    /// ```
    public static let shared = Client(apiKey: Client.config.apiKey,
                                      appId: Client.config.appId,
                                      baseURL: Client.config.baseURL,
                                      networkProvider: Client.config.networkProvider,
                                      callbackQueue: Client.config.callbackQueue,
                                      logsEnabled: Client.config.logsEnabled)
    
    /// Checks if API key and App Id are valid.
    public var isValid: Bool {
        return !apiKey.isEmpty && !appId.isEmpty
    }
    
    private init(apiKey: String,
                 appId: String,
                 baseURL: BaseURL = BaseURL(),
                 networkProvider: NetworkProvider? = nil,
                 callbackQueue: DispatchQueue = .main,
                 logsEnabled: Bool = false) {
        if !apiKey.isEmpty, logsEnabled {
            ClientLogger.logger("📰", "", "Stream Feed v.\(Client.version)")
            ClientLogger.logger("🔑", "", apiKey)
            ClientLogger.logger("🔗", "", baseURL.description)
        }
        
        self.apiKey = apiKey
        self.appId = appId
        self.baseURL = baseURL
        self.callbackQueue = callbackQueue
        let workingQueue = DispatchQueue(label: "io.getstream.Client.\(baseURL.url.host ?? "")", qos: .userInitiated)
        self.workingQueue = workingQueue
        logger = logsEnabled ? ClientLogger(icon: "🐴") : nil
        networkAuthorization = AuthorizationMoyaPlugin()
        
        if let networkProvider = networkProvider {
            self.networkProvider = networkProvider
        } else {
            self.networkProvider =
                NetworkProvider(endpointClosure: { Client.endpointMapping($0, apiKey: apiKey, baseURL: baseURL) },
                                callbackQueue: workingQueue,
                                plugins: [networkAuthorization])
        }
        
        checkAPIKey()
    }
    
    private func checkAPIKey() {
        if apiKey.isEmpty {
            ClientLogger.logger("❌❌❌", "", "The Stream Feed Client didn't setup properly. "
                + "You are trying to use it before setup the API Key.")
            Thread.callStackSymbols.forEach { ClientLogger.logger("", "", $0) }
        }
    }
}

extension Client {
    /// GetStream version number.
    public static let version: String = Bundle(for: Client.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    
    /// Default headers.
    static let headers: [String : String] = [
        "X-Stream-Client": "stream-swift-client-\(Client.version)",
        "X-Stream-Device": UIDevice.current.name,
        "X-Stream-OS": "\(UIDevice.current.systemName)\(UIDevice.current.systemVersion)"]
}

extension Client: CustomStringConvertible {
    public var description: String {
        return "GetStream Client v.\(Client.version) appId: \(appId)"
    }
}

// MARK: - Endpoint Request Parameters Mapping

extension Client {
    /// Add the app key parameter as an URL parameter for each request.
    static func endpointMapping(_ target: MultiTarget, apiKey: String, baseURL: BaseURL) -> Endpoint {
        let appKeyParameter = ["api_key": apiKey]
        var task: Task = target.task
        
        switch target.task {
        case .requestPlain:
            task = .requestParameters(parameters: appKeyParameter, encoding: URLEncoding.default)
            
        case let .requestParameters(parameters, encoding):
            if encoding is URLEncoding {
                task = .requestParameters(parameters: parameters.merged(with: appKeyParameter), encoding: encoding)
            } else {
                task = .requestCompositeParameters(bodyParameters: parameters,
                                                   bodyEncoding: encoding,
                                                   urlParameters: appKeyParameter)
            }
            
        case let .requestCompositeParameters(bodyParameters, bodyEncoding, parameters):
            task = .requestCompositeParameters(bodyParameters: bodyParameters,
                                               bodyEncoding: bodyEncoding,
                                               urlParameters: parameters.merged(with: appKeyParameter))
            
        case let .requestJSONEncodable(encodable):
            if let data = try? JSONEncoder.default.encode(AnyEncodable(encodable)) {
                if target.method == .get {
                    do {
                        if let json = (try JSONSerialization.jsonObject(with: data)) as? JSON {
                            task = .requestParameters(parameters: json.merged(with: appKeyParameter), encoding: URLEncoding.default)
                        }
                    } catch {
                        print("⚠️", #function, "Can't decode the JSON from the encodabledata for a GET request", error)
                    }
                } else {
                    task = .requestCompositeData(bodyData: data, urlParameters: appKeyParameter)
                }
            } else {
                print("⚠️", #function, "Can't encode object", encodable)
            }
            
        case let .requestCustomJSONEncodable(encodable, encoder: encoder):
            task = .requestJSONEncodable(encodable, encoder: encoder, urlParameters: appKeyParameter)
            
        case let .requestData(data):
            task = .requestCompositeData(bodyData: data, urlParameters: appKeyParameter)
            
        case let .requestCompositeData(bodyData, parameters):
            task = .requestCompositeData(bodyData: bodyData, urlParameters: parameters.merged(with: appKeyParameter) )
            
        case let .uploadMultipart(multipartFormData):
            task = .uploadCompositeMultipart(multipartFormData, urlParameters: appKeyParameter)
            
        case let .uploadCompositeMultipart(multipartFormData, parameters):
            task = .uploadCompositeMultipart(multipartFormData, urlParameters: parameters.merged(with: appKeyParameter))
            
        default:
            print("⚠️", #function, "Can't map the appKey parameter to the request", target.task)
        }
        
        return Endpoint(url: baseURL.endpointURLString(targetPath: target.path),
                        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                        method: target.method,
                        task: task,
                        httpHeaderFields: target.headers)
    }
}

extension Task {
    static func requestJSONEncodable(_ encodable: Encodable,
                                     encoder: JSONEncoder? = JSONEncoder.default,
                                     urlParameters: JSON) -> Task {
        if let encoder = encoder, let data = try? encoder.encode(AnyEncodable(encodable)) {
            return .requestCompositeData(bodyData: data, urlParameters: urlParameters)
        }
        
        print("⚠️", #function, "Can't encode object \(encodable)")
        return .requestPlain
    }
}

// MARK: - Requests

extension Client {
    /// Make a request with a given endpoint.
    @discardableResult
    func request(endpoint: TargetType, completion: @escaping ClientCompletion) -> Cancellable {
        if token.isEmpty {
            completion(.failure(.clientSetup("Network layer wasn't setup. Probably Token or User wasn't provided or it was bad.")))
            return SimpleCancellable()
        }
        
        logger?.log(endpoint)
        
        return networkProvider.request(MultiTarget(endpoint)) { [weak self] result in
            guard let self = self else {
                completion(.failure(.unexpectedError(nil)))
                return
            }
            
            do {
                let response: Moya.Response = try result.get()
                self.consecutiveFailures = 0
                self.logger?.log(response.response, data: response.data)
                
                if let json = try response.mapJSON() as? JSON {
                    if json["exception"] != nil {
                        completion(.failure(.server(.init(json: json))))
                    } else {
                        completion(.success(response))
                    }
                } else {
                    completion(.failure(.jsonInvalid(String(data: response.data, encoding: .utf8))))
                }
            } catch let moyaError as MoyaError {
                if case .statusCode(let moyaErrorResponse) = moyaError,
                    moyaErrorResponse.statusCode >= 429,
                    moyaErrorResponse.statusCode <= 500,
                    self.retry(endpoint: endpoint, completion: completion) {
                    return
                }
                
                if case .underlying(let error, _) = moyaError,
                    let urlError = error as? URLError,
                    urlError.errorCode == URLError.timedOut.rawValue,
                    self.retry(endpoint: endpoint, completion: completion) {
                    return
                }
                
                completion(.failure(moyaError.clientError))
                
            } catch {
                completion(.failure(.unknownError(error.localizedDescription, error)))
            }
        }
    }
    
    private func retry(endpoint: TargetType, completion: @escaping ClientCompletion) -> Bool {
        guard consecutiveFailures < 5 else {
            consecutiveFailures = 0
            return false
        }
        
        print("⚠️ Retry request: ", endpoint)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval.random(in: 0.1...1)) {
            self.request(endpoint: endpoint, completion: completion)
        }
        
        consecutiveFailures += 1
        
        return true
    }
}

// MARK: - Config

extension Client {
    /// A configuration for the shared Stream `Client`.
    public struct Config {
        let apiKey: String
        let appId: String
        let baseURL: BaseURL
        let callbackQueue: DispatchQueue
        let logsEnabled: Bool
        let networkProvider: NetworkProvider?
        
        /// Setup a configuration for the shared Stream `Client`.
        ///
        /// - Parameters:
        ///     - apiKey: the Stream API key
        ///     - appId: the Stream APP id
        ///     - baseURL: the client URL
        ///     - callbackQueue: a callback queue for completion requests.
        ///     - logsEnabled: if enabled the client will show logs for requests.
        public init(apiKey: String,
                    appId: String,
                    baseURL: BaseURL = BaseURL(),
                    callbackQueue: DispatchQueue = .main,
                    logsEnabled: Bool = false) {
            self.init(apiKey: apiKey,
                      appId: appId,
                      baseURL: baseURL,
                      callbackQueue: callbackQueue,
                      logsEnabled: logsEnabled,
                      networkProvider: nil)
        }
        
        init(apiKey: String,
             appId: String,
             baseURL: BaseURL = BaseURL(),
             callbackQueue: DispatchQueue = .main,
             logsEnabled: Bool = false,
             networkProvider: NetworkProvider?) {
            self.apiKey = apiKey
            self.appId = appId
            self.baseURL = baseURL
            self.callbackQueue = callbackQueue
            self.logsEnabled = logsEnabled
            self.networkProvider = networkProvider
        }
    }
}
