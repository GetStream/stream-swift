//
//  FeedGroup.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct FeedGroup: CustomStringConvertible, Codable {
    private static let separator: Character = ":"
    
    /// The name of the feed group, for instance user, trending, flat, timeline etc. For example: flat, timeline.
    let feedSlug: String
    /// The owner of the given feed.
    let userId: String
    
    /// The feed group id. E.g. `timeline:123`
    public var description: String {
        return feedSlug.appending(String(FeedGroup.separator)).appending(userId)
    }
    
    public init(feedSlug: String, userId: String) {
        self.feedSlug = feedSlug
        self.userId = userId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        
        if id.isEmpty {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot initialize FeedGroup from an empty string")
        }
        
        let pair = id.split(separator: FeedGroup.separator).map { String($0) }
        
        if pair.count != 2 {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot initialize FeedGroup from a currupted string: \(id)")
        }
        
        self.init(feedSlug: pair[0], userId: pair[1])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
