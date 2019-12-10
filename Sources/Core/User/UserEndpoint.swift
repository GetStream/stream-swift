//
//  UserEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum UserEndpoint {
    case create(_ user: UserProtocol, _ getOrCreate: Bool)
    case get(_ userId: String, _ withFollowCounts: Bool)
    case update(_ user: UserProtocol)
    case delete(_ userId: String)
}

extension UserEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case .create:
            return "user/"
        case .get(let id, _), .delete(let id):
            return "user/\(id)/"
        case .update(let user):
            return "user/\(user.id)/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        case .get:
            return .get
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case let .create(user, getOrCreate):
            return .requestJSONEncodable(user, urlParameters: ["get_or_create": getOrCreate])
            
        case .get(_, let withFollowCounts):
            return .requestParameters(parameters: ["with_follow_counts": withFollowCounts], encoding: URLEncoding.default)
            
        case .update(let user):
            return .requestJSONEncodable(user)
            
        case .delete:
            return .requestPlain
        }
    }
    
    var sampleJSON: String {
        switch self {
        case .create, .get:
            return """
            {"created_at":"2018-12-20T15:41:25.181144Z","updated_at":"2018-12-20T15:41:25.181144Z","id":"eric","data":{"name":"Eric"},"duration":"2.10ms"}
            """
            
        case .update:
            return """
            {"created_at":"2018-12-20T15:41:25.181144Z","updated_at":"2018-12-20T15:41:25.181144Z","id":"eric","data":{"name":"Eric Updated"},"duration":"2.10ms"}
            """

        case .delete:
            return "{}"
        }
    }
}
