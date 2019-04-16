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
    
    /// A feed id.
    public let feedId: FeedId
    /// A target feed id.
    public let targetFeedId: FeedId
    /// A created date.
    public let created: Date
    /// An updated date.
    public let updated: Date?
}
