//
//  Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A default reaction type with `EmptyReactionExtraData` and `User` types.
public typealias DefaultReaction = Reaction<EmptyReactionExtraData, User>

/// A reaction type.
public final class Reaction<T: ReactionExtraDataProtocol, U: UserProtocol>: ReactionProtocol {
    private enum CodingKeys: String, CodingKey {
        case id
        case activityId = "activity_id"
        case safeUser = "user"
        case kind
        case created = "created_at"
        case updated = "updated_at"
        case data
        case parentId = "parent"
        case userOwnChildren = "own_children"
        case latestChildren = "latest_children"
        case childrenCounts = "children_counts"
    }
    
    /// Reaction id.
    public let id: String
    /// Activity id for the reaction.
    public let activityId: String
    /// A wrapper for the user of the reaction.
    public let safeUser: MissingReference<U>
    /// User of the reaction.
    public var user: U {
        return safeUser.value
    }
    /// Type of reaction.
    public let kind: ReactionKind
    /// When the reaction was created.
    public let created: Date
    /// When the reaction was last updated.
    public let updated: Date?
    /// An extra data for the reaction.
    public let data: T
    /// Id of the parent reaction. Empty unless the reaction is a child reaction.
    public let parentId: String?
    /// User own children reactions, grouped by reaction type.
    public var userOwnChildren: [ReactionKind: [Reaction<T, U>]]?
    /// Children reactions, grouped by reaction type.
    public var latestChildren: [ReactionKind: [Reaction<T, U>]]
    /// Child reaction count, grouped by reaction kind
    public var childrenCounts: [ReactionKind: Int]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        activityId = try container.decode(String.self, forKey: .activityId)
        safeUser = try container.decodeIfPresent(MissingReference<U>.self, forKey: .safeUser) ?? MissingReference<U>.missed()
        kind = try container.decode(String.self, forKey: .kind)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        data = try container.decode(T.self, forKey: .data)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        userOwnChildren = try container.decodeIfPresent([ReactionKind: [Reaction<T, U>]].self, forKey: .userOwnChildren)
        latestChildren = try container.decode([ReactionKind: [Reaction<T, U>]].self, forKey: .latestChildren)
        childrenCounts = try container.decode([ReactionKind: Int].self, forKey: .childrenCounts)
    }
    
    /// Skip encoding.
    public func encode(to encoder: Encoder) throws {}
    
    /// Equatable.
    public static func == (lhs: Reaction<T, U>, rhs: Reaction<T, U>) -> Bool {
        return lhs === rhs || (!lhs.id.isEmpty && lhs.id == rhs.id)
    }
}
