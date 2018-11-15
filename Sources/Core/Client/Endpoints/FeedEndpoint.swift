//
//  FeedEndpoint.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 07/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum FeedEndpoint {
    case feed(_ feedId: FeedId, pagination: FeedPagination)
    case add(_ activity: ActivityProtocol, feedId: FeedId)
    case deleteById(_ id: UUID, feedId: FeedId)
    case deleteByForeignId(_ foreignId: String, feedId: FeedId)
}

extension FeedEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
    var path: String {
        switch self {
        case .feed(let feedId, _):
            return "feed/\(feedId.feedSlug)/\(feedId.userId)/"
        case .add(_, let feedId):
            return "feed/\(feedId.feedSlug)/\(feedId.userId)/"
        case let .deleteById(activityId, feedId):
            return "feed/\(feedId.feedSlug)/\(feedId.userId)/\(activityId.uuidString.lowercased())/"
        case let .deleteByForeignId(foreignId, feedId):
            return "feed/\(feedId.feedSlug)/\(feedId.userId)/\(foreignId)/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .feed:
            return .get
        case .add:
            return .post
        case .deleteById:
            return .delete
        case .deleteByForeignId:
            return .delete
        }
    }
    
    var sampleData: Data {
        switch self {
        case .feed:
            return """
            {"results":[
                {"actor":"eric","foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D","id":"9b5b3540-e825-11e8-8080-800016ff21e4","object":"Hello world 3","origin":null,"target":"","time":"2018-11-14T15:54:45.268000","to":["timeline:jessica"],"verb":"tweet"},
                {"actor":"eric","foreign_id":"1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6","id":"815b4fa0-e7fc-11e8-8080-80007911093a","object":"Hello world 2","origin":null,"target":"","time":"2018-11-14T11:00:32.282000","verb":"tweet"},
                {"actor":"eric","foreign_id":"FFBE449A-54B1-4701-A1E1-79E5DD5AF4BD","id":"2737dc60-e7fb-11e8-8080-80014193e462","object":"Hello world 1","origin":null,"target":"","time":"2018-11-14T10:50:51.558000","verb":"tweet"}],
            "next":"",
            "duration":"15.73ms"}
            """.data(using: .utf8) ?? Data()
            
        default:
                return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .feed(_, let pagination):
            if case .none = pagination {
                return .requestPlain
            }
            
            return .requestParameters(parameters: pagination.parameters, encoding: URLEncoding.default)
            
        case .add(let activity, feedId: _):
            return .requestCustomJSONEncodable(activity, encoder: .stream)
            
        case .deleteById:
            return .requestPlain
            
        case .deleteByForeignId:
            return .requestParameters(parameters: ["foreign_id": 1], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

// MARK: - Feed Pagination

public enum FeedPagination {
    public static let defaultLimit = 25
    
    /// Default limit is 25. (Defined in `FeedPagination.defaultLimit`)
    case none
    
    /// The amount of activities requested from the APIs.
    case limit(_ limit: Int)
    
    /// The offset of requesting activities.
    /// - Note: Using `lessThan` or `lessThanOrEqual` for pagination is preferable to using `offset`.
    case offset(_ offset: Int, limit: Int)
    
    /// Filter the feed on ids greater than the given value.
    case greaterThan(id: String, limit: Int)
    
    /// Filter the feed on ids greater than or equal to the given value.
    case greaterThanOrEqual(id: String, limit: Int)
    
    /// Filter the feed on ids smaller than the given value.
    case lessThan(id: String, limit: Int)
    
    /// Filter the feed on ids smaller than or equal to the given value.
    case lessThanOrEqual(id: String, limit: Int)
    
    /// Parameters for a request.
    fileprivate var parameters: [String: Any] {
        var addLimit: Int = FeedPagination.defaultLimit
        var params: [String: Any] = [:]
        
        switch self {
        case .none:
            return [:]
        case .limit(let limit):
            addLimit = limit
        case let .offset(offset, limit):
            params["offset"] = offset
            addLimit = limit
        case let .greaterThan(id, limit):
            params["id_gt"] = id
            addLimit = limit
        case let .greaterThanOrEqual(id, limit):
            params["id_gte"] = id
            addLimit = limit
        case let .lessThan(id, limit):
            params["id_lt"] = id
            addLimit = limit
        case let .lessThanOrEqual(id, limit):
            params["id_lte"] = id
            addLimit = limit
        }
        
        if addLimit != FeedPagination.defaultLimit {
            params["limit"] = addLimit
        }
        
        return params
    }
}
