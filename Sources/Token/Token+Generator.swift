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
    public init?(secret: String, resource: String = "*", permission: Permission = .all, feedGroup: FeedGroup? = nil) {
        let algorithm = JWTAlgorithm.hs256(secret)
        var payload = JWTPayload()
        
        payload.customFields = ["resource": EncodableValue(value: resource),
                                "action": EncodableValue(value: permission.rawValue),
                                "feed_id": EncodableValue(value: feedGroup?.feedSlug.appending(feedGroup?.userId ?? "") ?? "*")]
        
        let jwt = JWT(payload: payload, algorithm: algorithm)
        
        if let token = jwt?.rawString {
            self = token
        } else {
            return nil
        }
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
