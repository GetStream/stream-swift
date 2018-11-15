//
//  Token+Generator.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import SwiftyJWT

extension Token {
    /// Generate the Stream token with a given secret.
    ///
    /// - Parameters:
    ///     - secret: a secret string.
    ///     - resource: a resource string, e.g. feed
    ///     - permission: a permissionm e.g. read or write
    ///     - feedId: a `FeedId` or any as by default.
    public init?(secret: String, resource: Resource = .all, permission: Permission = .all, feedId: FeedId = .any) {
        let algorithm = JWTAlgorithm.hs256(secret)
        var payload = JWTPayload()
        
        payload.customFields = ["resource": EncodableValue(value: resource.rawValue),
                                "action": EncodableValue(value: permission.rawValue),
                                "feed_id": EncodableValue(value: feedId.description)]
        
        let jwt = JWT(payload: payload, algorithm: algorithm)
        
        if let token = jwt?.rawString {
            self = token
        } else {
            return nil
        }
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
