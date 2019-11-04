//
//  Client.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

typealias ClientCompletionResult = Result<Moya.Response, ClientError>
typealias ClientCompletion = (_ result: ClientCompletionResult) -> Void
typealias NetworkProvider = MoyaProvider<MultiTarget>

/// GetStream client.
public final class Client {
    let apiKey: String
    let appId: String
    let token: Token
    let callbackQueue: DispatchQueue
    let workingQueue: DispatchQueue
    
    private let networkProvider: NetworkProvider
    private var consecutiveFailures = 0
    let logger: ClientLogger?
    
    /// The current user id from the Token.
    public private(set) var currentUserId: String?
    /// The current user.
    public var currentUser: UserProtocol?
    
    /// A configuration to initialize the shared Client.
    public static var config = Config(apiKey: "", appId: "", token: "")
    
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
                                      token: Client.config.token,
                                      baseURL: Client.config.baseURL,
                                      callbackQueue: Client.config.callbackQueue,
                                      logsEnabled: Client.config.logsEnabled)
    
    /// Checks if Stream keys are valid.
    public var isValid: Bool {
        return !apiKey.isEmpty && !appId.isEmpty && token.isValid
    }
    
    /// Create a GetStream client for making network requests.
    ///
    /// - Parameters:
    ///     - apiKey: the Stream API key
    ///     - appId: the Stream APP id
    ///     - token: the client token
    ///     - baseURL: the client URL
    ///     - callbackQueue: a callback queue for completion requests.
    ///     - logsEnabled: if enabled the client will show logs for requests.
    public convenience init(apiKey: String,
                            appId: String,
                            token: Token,
                            baseURL: BaseURL = BaseURL(),
                            callbackQueue: DispatchQueue = .main,
                            logsEnabled: Bool = false) {
        var moyaPlugins: [PluginType] = [AuthorizationMoyaPlugin(token: token)]
        let workingQueue = DispatchQueue(label: "io.getstream.Client.\(baseURL.url.host ?? "")", qos: .userInitiated)
        let endpointClosure: NetworkProvider.EndpointClosure = { Client.endpointMapping($0, apiKey: apiKey, baseURL: baseURL) }
        let moyaProvider = NetworkProvider(endpointClosure: endpointClosure, callbackQueue: workingQueue, plugins: moyaPlugins)
        
        self.init(apiKey: apiKey,
                  appId: appId,
                  token: token,
                  networkProvider: moyaProvider,
                  workingQueue: workingQueue,
                  callbackQueue: callbackQueue,
                  logsEnabled: logsEnabled)
    }
    
    init(apiKey: String,
         appId: String,
         token: Token,
         networkProvider: NetworkProvider,
         workingQueue: DispatchQueue = .global(),
         callbackQueue: DispatchQueue = .main,
         logsEnabled: Bool = false) {
        self.apiKey = apiKey
        self.appId = appId
        self.token = token
        self.networkProvider = networkProvider
        self.workingQueue = workingQueue
        self.callbackQueue = callbackQueue
        logger = logsEnabled ? ClientLogger(icon: "🐴") : nil
        parseUserId()
    }
    
    private func parseUserId() {
        if let payloadJSON = token.payload, let userId = payloadJSON["user_id"] as? String {
            currentUserId = userId
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
            if let data = try? JSONEncoder.stream.encode(AnyEncodable(encodable)) {
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
                                     encoder: JSONEncoder? = JSONEncoder.stream,
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
        logger?.log("\(endpoint)")
        
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
        let token: Token
        let baseURL: BaseURL
        let callbackQueue: DispatchQueue
        let logsEnabled: Bool
        
        /// Setup a configuration for the shared Stream `Client`.
        ///
        /// - Parameters:
        ///     - apiKey: the Stream API key
        ///     - appId: the Stream APP id
        ///     - token: the client token
        ///     - baseURL: the client URL
        ///     - callbackQueue: a callback queue for completion requests.
        ///     - logsEnabled: if enabled the client will show logs for requests.
        public init(apiKey: String,
                    appId: String,
                    token: Token,
                    baseURL: BaseURL = BaseURL(),
                    callbackQueue: DispatchQueue = .main,
                    logsEnabled: Bool = false) {
            self.apiKey = apiKey
            self.appId = appId
            self.token = token
            self.baseURL = baseURL
            self.callbackQueue = callbackQueue
            self.logsEnabled = logsEnabled
        }
    }
}
