//
//  Token+Generator.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import JWT

fileprivate typealias Claims = [String: String]

extension Token {
    /// Generate the Stream token with a given secret and claims.
    ///
    /// - Parameters:
    ///     - secretData: a secret data.
    ///     - resource: a resource string, e.g. feed
    ///     - permission: a permissionm e.g. read or write
    ///     - feedId: a `FeedId` or any as by default.
    public init(secretData: Data, resource: Resource = .all, permission: Permission = .all, feedId: FeedId = .any) {
        self = Token.jwt(secretData: secretData, claims: Token.claims(resource: resource, permission: permission, feedId: feedId))
    }
    
    /// Generate the Stream token with a given secret and user id with full access.
    ///
    /// - Parameters:
    ///     - secretData: a secret data.po token
    ///     - userId: a `userId`.
    public init(secretData: Data, userId: String) {
        self = Token.jwt(secretData: secretData, claims: Token.claims(userId: userId))
    }
    
    private static func jwt(secretData: Data, claims: Claims) -> Token {
        return JWT.encode(claims: claims, algorithm: .hs256(secretData))
    }
    
    private static func claims(resource: Resource? = nil,
                       permission: Permission? = nil,
                       feedId: FeedId? = nil,
                       userId: String? = nil) -> Claims {
        var claims: Claims = [:]
        
        if let resource = resource {
            claims["resource"] = resource.rawValue
        }
        
        if let permission = permission {
            claims["action"] = permission.rawValue
        }
        
        if let feedId = feedId {
            claims["feed_id"] = feedId.togetherWithSeparator
        }
        
        if let userId = userId {
            claims["user_id"] = userId
        }
        
        return claims
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
