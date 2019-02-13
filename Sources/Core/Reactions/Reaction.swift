//
//  Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias DefaultReaction = Reaction<EmptyReactionExtraData, User>

// MARK: - Reaction Protocol

public protocol ReactionProtocol: Codable {
    /// Reaction id.
    var id: String { get }
    /// Type of reaction.
    var kind: ReactionKind { get }
}

// MARK: - Reaction

public final class Reaction<T: ReactionExtraDataProtocol, U: UserProtocol>: ReactionProtocol, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id
        case activityId = "activity_id"
        case user
        case kind
        case created = "created_at"
        case updated = "updated_at"
        case data
        case parentId = "parent"
        case ownChildren = "own_children"
        case latestChildren = "latest_children"
        case childrenCounts = "children_counts"
    }
    
    /// Reaction id.
    public let id: String
    /// Activity id for the reaction.
    public let activityId: String
    /// User of the reaction.
    public let user: U
    /// Type of reaction.
    public let kind: ReactionKind
    /// When the reaction was created.
    public let created: Date
    /// When the reaction was last updated.
    public let updated: Date?
    public let data: T
    /// Id of the parent reaction. Empty unless the reaction is a child reaction.
    public let parentId: String?
    /// User own children reactions, grouped by reaction type.
    public var ownChildren: [ReactionKind: [Reaction<T, U>]]?
    /// Children reactions, grouped by reaction type.
    public var latestChildren: [ReactionKind: [Reaction<T, U>]]
    /// Child reaction count, grouped by reaction kind
    public var childrenCounts: [ReactionKind: Int]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        activityId = try container.decode(String.self, forKey: .activityId)
        user = try container.decode(U.self, forKey: .user)
        kind = try container.decode(String.self, forKey: .kind)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        data = try container.decode(T.self, forKey: .data)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        ownChildren = try container.decodeIfPresent([ReactionKind: [Reaction<T, U>]].self, forKey: .ownChildren)
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

// MARK: - User own reaction of the reaction

extension Reaction {
    /// Check the user reactions for the reaction.
    ///
    /// - Parameter reactionKind: a kind of the child reaction.
    /// - Returns: true if exists the child reaction of the user.
    public func hasUserOwnChildReaction(_ reactionKind: ReactionKind) -> Bool {
        return (ownChildren?[reactionKind]?.count ?? 0) > 0
    }
    
    /// Try to get the first user child reaction.
    ///
    /// - Parameter reactionKind: a kind of the child reaction.
    /// - Returns: the user child reaction.
    public func userOwnChildReaction(_ reactionKind: ReactionKind) -> Reaction<T, U>? {
        return ownChildren?[reactionKind]?.first
    }
}

// MARK: - Child reactions

extension Reaction {
    
    /// Update the reaction with a new user own child reaction.
    ///
    /// - Parameter reaction: a new user own reaction.
    public func addOwnChild(_ reaction: Reaction<T, U>) {
        var ownChildren = self.ownChildren ?? [:]
        var latestChildren = self.latestChildren
        var childrenCounts = self.childrenCounts
        ownChildren[reaction.kind, default: []].insert(reaction, at: 0)
        latestChildren[reaction.kind, default: []].insert(reaction, at: 0)
        childrenCounts[reaction.kind, default: 0] += 1
        self.ownChildren = ownChildren
        self.latestChildren = latestChildren
        self.childrenCounts = childrenCounts
    }
    
    /// Delete an existing user own child reaction for the reaction.
    ///
    /// - Parameter reaction: an existing user own reaction.
    public func removeOwnChild(_ reaction: Reaction<T, U>) {
        var ownChildren = self.ownChildren ?? [:]
        var latestChildren = self.latestChildren
        var childrenCounts = self.childrenCounts
        
        if let firstIndex = ownChildren[reaction.kind]?.firstIndex(of: reaction) {
            ownChildren[reaction.kind, default: []].remove(at: firstIndex)
            self.ownChildren = ownChildren
            
            if let firstIndex = latestChildren[reaction.kind]?.firstIndex(of: reaction) {
                latestChildren[reaction.kind, default: []].remove(at: firstIndex)
                self.latestChildren = latestChildren
            }
            
            if let count = childrenCounts[reaction.kind], count > 0 {
                childrenCounts[reaction.kind, default: 0] = count - 1
                self.childrenCounts = childrenCounts
            }
        }
    }
}
