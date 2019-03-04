//
//  ReactionKind.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

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
    
    public var isLiked: Bool {
        return hasUserOwnReaction(.like)
    }
    
    public var likesCount: Int {
        return userOwnReactionsCount(.like)
    }
    
    public var likedReaction: ReactionType? {
        return userOwnReaction(.like)
    }
    
    // MARK: - Reposts
    
    public var isReposted: Bool {
        return hasUserOwnReaction(.repost)
    }
    
    public var repostsCount: Int {
        return userOwnReactionsCount(.repost)
    }
    
    public var repostReaction: ReactionType? {
        return userOwnReaction(.repost)
    }
    
    // MARK: - Comments
    
    public var commentsCount: Int {
        return userOwnReactionsCount(.comment)
    }
}
