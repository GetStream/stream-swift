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

typealias JSON = [String: Any]
typealias ClientCompletion = (_ result: Result<Data, ClientError>) -> Void

public final class Client {
    private let moyaProvider: MoyaProvider<MultiTarget>
    private let apiKey: String
    private let appId: String
    private let token: Token
    private let baseURL: BaseURL
    
    /// The last rate limit response.
    public var rateLimit: RateLimit?
    
    /// Create a GetStream client for making network requests.
    ///
    /// - Parameters:
    ///     - apiKey: the Stream API key
    ///     - appId: the Stream APP id
    ///     - token: the client token
    ///     - baseURL: the client URL
    ///     - callbackQueue: propagated to Alamofire as callback queue. If nil the GetStream default queue will be used.
    public init(apiKey: String, appId: String, token: Token, baseURL: BaseURL = BaseURL(), callbackQueue: DispatchQueue? = nil) {
        self.apiKey = apiKey
        self.appId = appId
        self.token = token
        self.baseURL = baseURL
        let callbackQueue = callbackQueue ?? DispatchQueue(label: "\(baseURL.url.host ?? "io.getstream").Client")
        let moyaPlugins: [PluginType] = [NetworkLoggerPlugin(verbose: true, cURL: true), AuthorizationMoyaPlugin(token: token)]
        
        moyaProvider = MoyaProvider<MultiTarget>(endpointClosure: { Client.endpointMapping($0, apiKey: apiKey, baseURL: baseURL) },
                                                 callbackQueue: callbackQueue,
                                                 plugins: moyaPlugins)
    }
}

extension Client {
    /// GetStream version number.
    public static let version: String = Bundle(for: Client.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
}

extension Client: CustomStringConvertible {
    public var description: String {
        return "GetStream Client v.\(Client.version):\napiKey: \(apiKey)\nappId: \(appId)\nbaseURL: \(baseURL)\ntoken: \(token)"
    }
}

// MARK: - Endpoint Mapping

extension Client {
    /// Add the app key parameter as an URL parameter for each request.
    /// - Throws:
    ///     can throw ClientError
    private static func endpointMapping(_ target: MultiTarget, apiKey: String, baseURL: BaseURL) -> Endpoint {
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
                task = .requestCompositeData(bodyData: data, urlParameters: appKeyParameter)
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
            
        case let .uploadCompositeMultipart(data, parameters):
            task = .uploadCompositeMultipart(data, urlParameters: parameters.merged(with: appKeyParameter))
            
        default:
            print("⚠️", #function, "Can't map the appKey parameter to the request", target.task)
            break
        }
        
        return Endpoint(
            url: baseURL.endpointURLString(targetPath: target.path),
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: task,
            httpHeaderFields: target.headers
        )
    }
}

// MARK: - Requests

extension Client {
    /// Make a request with a given endpoint.
    func request(endpoint: TargetType, completion: @escaping ClientCompletion) -> Moya.Cancellable {
        return moyaProvider.request(MultiTarget(endpoint)) { [weak self] result in
            if case .success(let response) = result {
                self?.rateLimit = RateLimit(response: response)
                
                do {
                    if let json = try response.mapJSON() as? JSON {
                        if json["exception"] != nil {
                            completion(.failure(ClientError(json: json)))
                        } else {
                            completion(.success(response.data))
                        }
                    } else {
                        completion(.failure(.jsonInvalid))
                    }
                } catch let error as MoyaError {
                    completion(.failure(error.clientError))
                } catch {
                    completion(.failure(.unknown))
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
