//
//  ReactionKind.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A reaction kind type.
public typealias ReactionKind = String

// MARK: - Common Reaction Kinds

extension ReactionKind {
    /// A shared Like Reaction type.
    public static let like: ReactionKind = "like"
    /// A shared Comment Reaction type.
    public static let comment: ReactionKind = "comment"
    /// A shared Repost Reaction type.
    public static let repost: ReactionKind = "repost"
}

// MARK: - Helper for Common Reaction Kinds

extension ActivityProtocol where ReactionType: ReactionProtocol {
    
    // MARK: - Likes
    
    /// True if the current user like the activity. See `ReactionKind.like`.
    public var isUserLiked: Bool {
        return hasUserOwnReaction(.like)
    }
    
    /// A number of likes. See `ReactionKind.like`.
    public var likesCount: Int {
        return reactionCounts?[.like] ?? 0
    }
    
    /// A like reaction of the current user. See `ReactionKind.like`.
    public var userLikedReaction: ReactionType? {
        return userOwnReaction(.like)
    }
    
    // MARK: - Reposts
    
    /// True if the current user repost the activity. See `ReactionKind.repost`.
    public var isUserReposted: Bool {
        return hasUserOwnReaction(.repost)
    }
    
    /// A number of reposts. See `ReactionKind.repost`.
    public var repostsCount: Int {
        return reactionCounts?[.repost] ?? 0
    }
    
    /// A repost reaction of the current user. See `ReactionKind.repost`.
    public var userRepostReaction: ReactionType? {
        return userOwnReaction(.repost)
    }
    
    // MARK: - Comments
    
    /// A number of comments. See `ReactionKind.comment`.
    public var commentsCount: Int {
        return reactionCounts?[.comment] ?? 0
    }
}
