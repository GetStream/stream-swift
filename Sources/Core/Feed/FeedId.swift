//
//  FeedId.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct FeedId: CustomStringConvertible, Codable {
    private static let separator: Character = ":"
    
    /// The name of the feed group, for instance user, trending, flat, timeline etc. For example: flat, timeline.
    let feedSlug: String
    /// The owner of the given feed.
    let userId: String
    
    /// The feed group id, e.g. `timeline:123`
    public var description: String {
        if userId.isEmpty {
            return feedSlug
        }
        
        return feedSlug.appending(String(FeedId.separator)).appending(userId)
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
                                                   debugDescription: "Cannot initialize FeedId from an empty string")
        }
        
        let pair = id.split(separator: FeedId.separator).map { String($0) }
        
        if pair.count != 2 {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot initialize FeedId from a currupted string: \(id)")
        }
        
        self.init(feedSlug: pair[0], userId: pair[1])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension FeedId: Equatable {
    public static func == (lhs: FeedId, rhs: FeedId) -> Bool {
        return lhs.feedSlug == rhs.feedSlug && lhs.userId == rhs.userId
    }
}

// MARK: - FeedIds

public typealias FeedIds = [FeedId]

extension Array where Element == FeedId {
    var value: String {
        return map { $0.description }.joined(separator: ",")
    }
}
