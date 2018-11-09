//
//  GetStream.swift
//  Stream.io Inc
//
//  Created by Alexey Bukhtin on 06/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Require
import Result

public typealias Token = String
public typealias CompletionResult<T> = Result<[T], ClientError>
public typealias Completion<T> = (_ result: CompletionResult<T>) -> Void
public typealias Cancellable = Moya.Cancellable

typealias JSON = [String: Any]
typealias ClientCompletion = (_ result: Result<JSON, ClientError>) -> Void

public final class Client {
    private let moyaProvider: MoyaProvider<MultiTarget>
    private let apiKey: String
    private let appId: String
    private let token: Token
    private let baseURL: BaseURL
    
    /// Create a GetStream client for making network requests.
    ///
    /// - parameters:
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
    private static func endpointMapping(_ target: MultiTarget, apiKey: String, baseURL: BaseURL) -> Endpoint {
        let appKeyParameter = ["api_key": apiKey]
        let task: Task
        
        switch target.task {
        case .requestPlain:
            task = .requestParameters(parameters: appKeyParameter, encoding: URLEncoding.default)
            
        case .requestParameters(let parameters, let encoding):
            task = .requestCompositeParameters(bodyParameters: parameters,
                                               bodyEncoding: encoding,
                                               urlParameters: appKeyParameter)
            
        case .requestCompositeData(let bodyData, let urlParameters):
            task = .requestCompositeData(bodyData: bodyData, urlParameters: urlParameters.mergeFirst(with: appKeyParameter) )
            
        case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
            task = .requestCompositeParameters(bodyParameters: bodyParameters,
                                               bodyEncoding: bodyEncoding,
                                               urlParameters: urlParameters.mergeFirst(with: appKeyParameter))
            
        case let .uploadCompositeMultipart(data, urlParameters):
            task = .uploadCompositeMultipart(data, urlParameters: urlParameters.mergeFirst(with: appKeyParameter))
            
        default:
            task = target.task
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

fileprivate extension Dictionary {
    func mergeFirst(with other: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(other) { first, _ in first }
        return dict
    }
}

// MARK: - Requests

extension Client {
    /// Make a request with a given endpoint.
    func request(endpoint: TargetType, completion: @escaping ClientCompletion) -> Moya.Cancellable {
        return moyaProvider.request(MultiTarget(endpoint)) { result in
            if case .success(let response) = result {
                do {
                    if let json = try response.mapJSON() as? JSON {
                        if let statusCode = json["status_code"] as? Int, statusCode == 200 {
                            completion(.success(json))
                        } else {
                            completion(.failure(ClientError(json: json)))
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

// MARK: - Base URL

public struct BaseURL {
    let url: URL
    
    public init(location: Location = .default, service: Service = .api, version: String = "1.0") {
        url = URL(string: "https://\(location.rawValue)\(service.rawValue).stream-io-api.com/api/\(version)/").require()
    }
    
    public init(customURL: URL) {
        url = customURL
    }
    
    fileprivate func endpointURLString(targetPath: String) -> String {
        return (targetPath.isEmpty ? url : url.appendingPathComponent(targetPath)).absoluteString
    }
}

extension BaseURL {
    public enum Service: String {
        case api
        case personalization
        case analytics
    }
    
    public enum Location: String {
        case `default` = ""
        case usEast = "us-east-"
        case europeWest = "eu-west-"
        case singapore = "singapore-"
    }
}

extension BaseURL: CustomStringConvertible {
    public var description: String {
        return url.absoluteString
    }
}

extension Client {
    static let placeholderURL = URL(string: "https://getstream.io").require()
}
