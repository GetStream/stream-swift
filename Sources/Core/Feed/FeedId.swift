//
//  FeedId.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A feed identifier based on `feedSlug` and `userId`.
public struct FeedId: CustomStringConvertible, Codable {
    
    /// The name of the feed group, for instance user, trending, flat, timeline etc. For example: flat, timeline.
    public let feedSlug: String
    /// The owner of the given feed.
    public let userId: String
    
    /// The feed group id, e.g. `timeline123`
    public var together: String {
        return feedSlug.appending(userId)
    }
    
    /// The feed group id with the colon separator, e.g. `timeline:123`
    public var togetherWithColon: String {
        if userId.isEmpty {
            return feedSlug
        }
        
        return feedSlug.appending(":").appending(userId)
    }
    
    /// The feed group id with the slash separator, e.g. `timeline/123`
    public var togetherWithSlash: String {
        if userId.isEmpty {
            return feedSlug
        }
        
        return feedSlug.appending("/").appending(userId)
    }
    
    public var description: String {
        return togetherWithColon
    }
    
    public init(feedSlug: String, userId: String) {
        self.feedSlug = feedSlug
        self.userId = userId
    }
    
    public init?(feedSlug: String) {
        if let userId = Client.shared.currentUserId {
            self.feedSlug = feedSlug
            self.userId = userId
        } else {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        
        if id.isEmpty {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot initialize FeedId from an empty string")
        }
        
        let pair = id.split(separator: ":").map { String($0) }
        
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

extension FeedId {
    public static let any = FeedId(feedSlug: "*", userId: "")
    public static let user = FeedId(feedSlug: "user")
    public static let timeline = FeedId(feedSlug: "timeline")
    public static let notification = FeedId(feedSlug: "notification")
    
    /// A user feed id with the given userId.
    public static func user(with userId: String) -> FeedId {
        return FeedId(feedSlug: "user", userId: userId)
    }
}

// MARK: - FeedIds

public typealias FeedIds = [FeedId]

extension Array where Element == FeedId {
    var value: String {
        return map { $0.description }.joined(separator: ",")
    }
}
