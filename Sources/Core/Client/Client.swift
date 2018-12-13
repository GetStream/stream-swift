//
//  Client.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

typealias ClientCompletionResult = Result<Response, ClientError>
typealias ClientCompletion = (_ result: ClientCompletionResult) -> Void
typealias NetworkProvider = MoyaProvider<MultiTarget>

/// GetStream client.
public final class Client {
    let apiKey: String
    let appId: String
    let token: Token
    
    private let networkProvider: NetworkProvider
    
    /// Create a GetStream client for making network requests.
    ///
    /// - Parameters:
    ///     - apiKey: the Stream API key
    ///     - appId: the Stream APP id
    ///     - token: the client token
    ///     - baseURL: the client URL
    ///     - callbackQueue: propagated to Alamofire as callback queue. If nil a GetStream default queue will be used.
    ///     - logsEnabled: if enabled the client will show logs for requests.
    public convenience init(apiKey: String,
                            appId: String,
                            token: Token,
                            baseURL: BaseURL = BaseURL(),
                            callbackQueue: DispatchQueue? = nil,
                            logsEnabled: Bool = false) {
        var moyaPlugins: [PluginType] = [AuthorizationMoyaPlugin(token: token)]
        
        if logsEnabled {
            moyaPlugins.append(NetworkLoggerPlugin(verbose: true))
        }
        
        let callbackQueue = callbackQueue
            ?? DispatchQueue(label: "io.getstream.Client.\(baseURL.url.host ?? "")", qos: .userInitiated)
        
        let endpointClosure: NetworkProvider.EndpointClosure = { Client.endpointMapping($0, apiKey: apiKey, baseURL: baseURL) }
        let moyaProvider = NetworkProvider(endpointClosure: endpointClosure, callbackQueue: callbackQueue, plugins: moyaPlugins)
        self.init(apiKey: apiKey, appId: appId, token: token, networkProvider: moyaProvider)
    }
    
    init(apiKey: String, appId: String, token: Token, networkProvider: NetworkProvider) {
        self.apiKey = apiKey
        self.appId = appId
        self.token = token
        self.networkProvider = networkProvider
    }
}

extension Client {
    /// GetStream version number.
    public static let version: String = Bundle(for: Client.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    
    /// Default headers.
    static let headers: [String : String] = ["X-Stream-Client": "stream-swift-client-\(Client.version)"]
}

extension Client: CustomStringConvertible {
    public var description: String {
        return "GetStream Client v.\(Client.version) appId: \(appId)"
    }
}

// MARK: - Endpoint Mapping

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
            if let data = try? JSONEncoder().encode(AnyEncodable(encodable)) {
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
            if let data = try? encoder.encode(AnyEncodable(encodable)) {
                task = .requestCompositeData(bodyData: data, urlParameters: appKeyParameter)
            } else {
                print("⚠️", #function, "Can't encode object \(encodable)")
            }
            
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

// MARK: - Requests

extension Client {
    /// Make a request with a given endpoint.
    @discardableResult
    func request(endpoint: TargetType, completion: @escaping ClientCompletion) -> Cancellable {
        return networkProvider.request(MultiTarget(endpoint)) { result in
            if case .success(let response) = result {
                do {
                    if let json = try response.mapJSON() as? JSON {
                        if json["exception"] != nil {
                            completion(.failure(.server(.init(json: json))))
                        } else {
                            completion(.success(response))
                        }
                    } else {
                        completion(.failure(.jsonInvalid))
                    }
                } catch let moyaError as MoyaError {
                    completion(.failure(moyaError.clientError))
                } catch {
                    completion(.failure(.unknownError(error.localizedDescription)))
                }
            } else if case .failure(let moyaError) = result {
                completion(.failure(moyaError.clientError))
            }
        }
    }
}

// MARK: - Rate Limit

extension Client {
    public struct RateLimit {
        public let limit: Int
        public let remaining: Int
        public let resetDate: Date
        
        init?(response: Response) {
            guard let headers = response.response?.allHeaderFields as? [String : Any],
                let limitString = headers["x-ratelimit-limit"] as? String,
                let limit = Int(limitString),
                let remainingString = headers["x-ratelimit-remaining"] as? String,
                let remaining = Int(remainingString),
                let resetString = headers["x-ratelimit-reset"] as? String,
                let resetTimeInterval = TimeInterval(resetString) else {
                    return nil
            }
            
            self.limit = limit
            self.remaining = remaining
            resetDate = Date(timeIntervalSince1970: resetTimeInterval)
        }
    }
}

extension Client.RateLimit: CustomStringConvertible {
    public var description: String {
        return "Limit rate: \(remaining)/\(limit). Reset at \(resetDate)"
    }
}
