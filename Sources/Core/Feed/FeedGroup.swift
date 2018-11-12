//
//  FeedGroup.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct FeedGroup {
    /// The name of the feed group, for instance user, trending, flat, timeline etc. For example: flat, timeline.
    let feedSlug: String
    /// The owner of the given feed.
    let userId: String
    
    public init(feedSlug: String, userId: String) {
        self.feedSlug = feedSlug
        self.userId = userId
    }
}
