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
    
    /// Create a GetStream client for making network requests.
    ///
    /// - parameters:
    ///     - apiKey: 
    public init(apiKey: String, appId: String, secretKey: String? = nil, location: Client.Location = .usEast) {
        let appKeyParameter = ["api_key": apiKey]
        
        // Add the app key parameter as an URL parameter for each request.
        func endpointMapping(for target: MultiTarget) -> Endpoint {
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

// MARK: - Extensions

fileprivate extension Dictionary {
    func mergeFirst(with other: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(other) { first, _ in first }
        return dict
    }
}
