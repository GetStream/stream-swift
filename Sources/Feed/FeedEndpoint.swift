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
    case add(activity: Activity, toFeed: FeedId)
}

extension FeedEndpoint: TargetType {
    var baseURL: URL {
        return Client.placeholderURL
    }
    
    var path: String {
        switch self {
        case .feed(let feedId, _):
            return "feed/\(feedId.feedSlug)/\(feedId.userId)/"
        case .add(activity: _, toFeed: let feedId):
            return "feed/\(feedId.feedSlug)/\(feedId.userId)/"
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
            
            return .requestParameters(parameters: pagination.parameters, encoding: JSONEncoding.default)
            
        case .add(activity: let activity, toFeed: _):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

// MARK: - Feed Pagination

public enum FeedPagination {
    /// Default limit is 25.
    case none
    
    /// The amount of activities requested from the APIs.
    case limit(_ limit: Int)
    
    /// The offset of requesting activities.
    /// - note: Using `lessThan` or `lessThanOrEqual` for pagination is preferable to using `offset`.
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
        switch self {
        case .none:
            return [:]
        case .limit(let limit):
            return ["limit": limit]
        case let .offset(offset, limit):
            return ["limit": limit, "offset": offset]
        case let .greaterThan(id, limit):
            return ["limit": limit, "id_gt": id]
        case let .greaterThanOrEqual(id, limit):
            return ["limit": limit, "id_gte": id]
        case let .lessThan(id, limit):
            return ["limit": limit, "id_lt": id]
        case let .lessThanOrEqual(id, limit):
            return ["limit": limit, "id_lte": id]
        }
    }
}
