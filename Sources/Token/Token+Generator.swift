//
//  Token+Generator.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream
import Require
import JWT

extension Token {
    /// Generate the Stream token with a given secret.
    ///
    /// - Parameters:
    ///     - secret: a secret string.
    ///     - resource: a resource string, e.g. feed
    ///     - permission: a permissionm e.g. read or write
    ///     - feedId: a `FeedId` or any as by default.
    public init(secret: String, resource: Resource = .all, permission: Permission = .all, feedId: FeedId = .any) {
        self = JWT.encode(claims: Token.payload(resource: resource, permission: permission, feedId: feedId),
                          algorithm: .hs256(secret.data(using: .utf8).require()))
    }
    
    static func payload(resource: Resource = .all, permission: Permission = .all, feedId: FeedId = .any) -> [String: Any] {
        return ["resource": resource.rawValue,
                "action": permission.rawValue,
                "feed_id": feedId.description]
    }
}

extension Token {
    public enum Resource: String {
        /// Allow access to any resource.
        case all = "*"
        /// Activities Endpoint.
        case activities
        /// Feed Endpoint.
        case feed
        /// Following + Followers Endpoint.
        case follower
    }
}

extension Token {
    public enum Permission: String {
        case all = "*"
        case read
        case write
        case delete
    }
}

extension FeedId {
    public static let any = FeedId(feedSlug: "*", userId: "")
}
