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

public final class Client {
    
    open static var location: Client.Location = .usEast
    
    public static var baseURL: URL {
        return URL(string: "https://\(location.rawValue)api.stream-io-api.com/api/v1.0/").require()
    }
    
    private let moyaProvider: MoyaProvider<MultiTarget>
    
    public init(apiKey: String, appId: String, secretKey: String? = nil, location: Client.Location = .usEast) {
        let appKeyParameters = ["api_key": apiKey]
        
        func mergeAppKeyParameters(with parameters: [String: Any]) -> [String: Any] {
            var parameters = parameters
            parameters.merge(appKeyParameters) { current, _ -> Any in current }
            return parameters
        }
        
        func endpointMapping(for target: MultiTarget) -> Endpoint {
            let task: Task
            
            switch target.task {
            case .requestPlain:
                task = .requestParameters(parameters: appKeyParameters, encoding: URLEncoding.default)
                
            case .requestParameters(let parameters, let encoding):
                task = .requestCompositeParameters(bodyParameters: parameters,
                                                   bodyEncoding: encoding,
                                                   urlParameters: appKeyParameters)
                
            case .requestCompositeData(let bodyData, let urlParameters):
                task = .requestCompositeData(bodyData: bodyData, urlParameters: mergeAppKeyParameters(with: urlParameters))
                
            case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
                task = .requestCompositeParameters(bodyParameters: bodyParameters,
                                                   bodyEncoding: bodyEncoding,
                                                   urlParameters: mergeAppKeyParameters(with: urlParameters))
                
            case let .uploadCompositeMultipart(data, urlParameters):
                task = .uploadCompositeMultipart(data, urlParameters: mergeAppKeyParameters(with: urlParameters))
                
            default:
                task = target.task
            }
            
            return Endpoint(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                method: target.method,
                task: task,
                httpHeaderFields: target.headers
            )
        }
        
        let moyaPlugins: [PluginType] = [NetworkLoggerPlugin(verbose: true),
                                         AuthorizationMoyaPlugin(apiKey: apiKey, appId: appId, secretKey: secretKey)]
        
        moyaProvider = MoyaProvider<MultiTarget>(endpointClosure: endpointMapping,
                                                 callbackQueue: DispatchQueue(label: "io.getstream.Client"),
                                                 plugins: moyaPlugins)
        
        Client.location = location
    }
}

// MARK: - Client Location

extension Client {
    public enum Location: String {
        case usEast = "us-east-"
        case europeWest = "eu-west-"
        case singapore = "singapore-"
    }
}

extension Client {
    /// Retrieve activities in a feed.
    ///
    /// - parameters:
    ///     - feedId: a feed id.
    ///     - pagination: specify a pagination options. Default is limit activities with 25.
    public func feed(with feedId: FeedId, pagination: FeedPagination = .none) {
        moyaProvider.request(MultiTarget(FeedEndpoint.feed(feedId, pagination: pagination))) { result in
            debugPrint(result)
        }
    }
}
