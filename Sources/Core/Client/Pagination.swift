//
//  Pagination.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// Pagination options.
public enum Pagination: Decodable {
    /// The default value for the pagination limit is 25.
    public static let defaultLimit = 25
    
    /// Default limit is 25. (Defined in `FeedPagination.defaultLimit`)
    case none
    
    /// The amount of activities requested from the APIs.
    case limit(_ limit: Int)
    
    /// The offset of requesting activities.
    /// - Note: Using `lessThan` or `lessThanOrEqual` for pagination is preferable to using `offset`.
    case offset(_ offset: Int)
    
    /// Filter the feed on ids greater than the given value.
    case greaterThan(_ id: String)
    
    /// Filter the feed on ids greater than or equal to the given value.
    case greaterThanOrEqual(_ id: String)
    
    /// Filter the feed on ids smaller than the given value.
    case lessThan(_ id: String)
    
    /// Filter the feed on ids smaller than or equal to the given value.
    case lessThanOrEqual(_ id: String)
    
    /// Combine `Pagination`'s with each other.
    ///
    /// It's easy to use with the `+` operator. Examples:
    /// ```
    /// var pagination = .limit(10) + .greaterThan("news123")
    /// pagination += .lessThan("news987")
    /// print(pagination)
    /// // It will print:
    /// // and(pagination: .and(pagination: .limit(10), another: .greaterThan("news123")),
    /// //     another: .lessThan("news987"))
    /// ```
    indirect case and(pagination: Pagination, another: Pagination)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let urlString = try container.decode(String.self)
        var pagination: Pagination = .none
        
        if let urlComponents = URLComponents(string: urlString), let queryItems = urlComponents.queryItems {
            queryItems.forEach { queryItem in
                if let value = queryItem.value, !value.isEmpty {
                    switch queryItem.name {
                    case "limit":
                        if let intValue = Int(value) {
                            pagination += .limit(intValue)
                        }
                    case "offset":
                        if let intValue = Int(value) {
                            pagination += .offset(intValue)
                        }
                    case "id_gt":
                        pagination += .greaterThan(value)
                    case "id_gte":
                        pagination += .greaterThanOrEqual(value)
                    case "id_lt":
                        pagination += .lessThan(value)
                    case "id_lte":
                        pagination += .lessThanOrEqual(value)
                    default:
                        break
                    }
                }
            }
        }
        
        self = pagination
    }
    
    /// Parameters for a request.
    var parameters: [String: Any] {
        var params: [String: Any] = [:]
        
        switch self {
        case .none:
            return [:]
        case .limit(let limit):
            params["limit"] = limit
        case let .offset(offset):
            params["offset"] = offset
        case let .greaterThan(id):
            params["id_gt"] = id
        case let .greaterThanOrEqual(id):
            params["id_gte"] = id
        case let .lessThan(id):
            params["id_lt"] = id
        case let .lessThanOrEqual(id):
            params["id_lte"] = id
        case let .and(pagination1, pagination2):
             params = pagination1.parameters.merged(with: pagination2.parameters)
        }
        
        return params
    }
}

// MARK: - Helper Operator

extension Pagination {
    /// An operator for combining Pagination's.
    public static func +(lhs: Pagination, rhs: Pagination) -> Pagination {
        if case .none = lhs {
            return rhs
        }
        
        if case .none = rhs {
            return lhs
        }
        
        return .and(pagination: lhs, another: rhs)
    }
    
    /// An operator for combining Pagination's.
    public static func +=(lhs: inout Pagination, rhs: Pagination) {
        lhs = lhs + rhs
    }
}
