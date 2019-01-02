//
//  Follower.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 19/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A feed Follower.
public struct Follower: Decodable {
    private enum CodingKeys: String, CodingKey {
        case feedId = "feed_id"
        case targetFeedId = "target_id"
        case created = "created_at"
        case updated = "updated_at"
    }
    
    public let feedId: FeedId
    public let targetFeedId: FeedId
    public let created: Date
    public let updated: Date?
}
