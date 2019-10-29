//
//  ReactionExtraDataProtocol.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A reaction extra data protocol.
public typealias ReactionExtraDataProtocol = Codable

// MARK: - Empty reaction extra data

/// A default empty type of `ReactionExtraDataProtocol`.
public struct EmptyReactionExtraData: ReactionExtraDataProtocol, Equatable {
    /// Shared empty reaction extra data.
    public static let shared = EmptyReactionExtraData()
}

/// MARK: - Comment

/// Comment reaction extra data.
public struct Comment: ReactionExtraDataProtocol {
    public let text: String
}

// MARK: - Like/Repost/Comment

/// Combine Likes/Reposts and Comment reaction extra data.
public enum ReactionExtraData: ReactionExtraDataProtocol {
    case empty
    case comment(_ text: String)
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .empty:
            try EmptyReactionExtraData.shared.encode(to: encoder)
        case .comment(let comment):
            try Comment(text: comment).encode(to: encoder)
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let comment = try? Comment(from: decoder) {
            self = .comment(comment.text)
        } else {
            self = .empty
        }
    }
}
