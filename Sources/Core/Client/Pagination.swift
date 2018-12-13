//
//  Pagination.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public enum Pagination {
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
    var parameters: [String: Any] {
        var addLimit: Int = Pagination.defaultLimit
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
        
        if addLimit != Pagination.defaultLimit {
            params["limit"] = addLimit
        }
        
        return params
    }
}
