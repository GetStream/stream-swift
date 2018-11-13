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
    case feed(_ feedGroup: FeedGroup, pagination: FeedPagination)
    case add(_ activity: ActivityProtocol, feedGroup: FeedGroup)
}

extension FeedEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
    var path: String {
        switch self {
        case .feed(let feedGroup, _):
            return "feed/\(feedGroup.feedSlug)/\(feedGroup.userId)/"
        case .add(_, let feedGroup):
            return "feed/\(feedGroup.feedSlug)/\(feedGroup.userId)/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .feed:
            return .get
        case .add:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .feed(_, let pagination):
            if case .none = pagination {
                return .requestPlain
            }
            
            return .requestParameters(parameters: pagination.parameters, encoding: URLEncoding.default)
            
        case .add(let activity, feedGroup: _):
            return .requestCustomJSONEncodable(activity, encoder: .stream)
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
