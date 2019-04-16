//
//  ReactionProtocol.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 28/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A reaction protocol.
public protocol ReactionProtocol: Codable, Equatable {
    associatedtype ExtraDataType = ReactionExtraDataProtocol
    associatedtype UserType = UserProtocol
    
    /// Reaction id.
    var id: String { get }
    /// A User of the reaction.
    var user: UserType { get }
    /// Type of reaction.
    var kind: ReactionKind { get }
    /// An extra data for the reaction.
    var data: ExtraDataType { get }
    /// User own children reactions, grouped by reaction type.
    var userOwnChildren: [ReactionKind: [Self]]? { get set }
    /// Children reactions, grouped by reaction type.
    var latestChildren: [ReactionKind: [Self]] { get set }
    /// Child reaction count, grouped by reaction kind
    var childrenCounts: [ReactionKind: Int] { get set }
}

// MARK: - User own child reactions

extension ReactionProtocol {
    
    /// Check if the user has own child reactions for the reaction with a given reaction kind.
    ///
    /// - Parameter reactionKind: a kind of the child reaction.
    /// - Returns: true if exists the child reaction of the user.
    public func hasUserOwnChildReaction(_ reactionKind: ReactionKind) -> Bool {
        return userOwnChildReactionsCount(reactionKind) > 0
    }
    
    /// The number of user own child reactions with a given reaction kind.
    ///
    /// - Parameter reactionKind: a kind of the child reaction.
    /// - Returns: the number of user own child reactions.
    public func userOwnChildReactionsCount(_ reactionKind: ReactionKind) -> Int {
        return userOwnChildren?[reactionKind]?.count ?? 0
    }
    
    /// Try to get the first user own child reaction.
    ///
    /// - Parameter reactionKind: a kind of the child reaction.
    /// - Returns: the user child reaction.
    public func userOwnChildReaction(_ reactionKind: ReactionKind) -> Self? {
        return userOwnChildren?[reactionKind]?.first
    }
}

// MARK: - Managing reactions

extension ReactionProtocol {
    
    /// Update the reaction with a new user own child reaction.
    ///
    /// - Parameter reaction: a new user own reaction.
    public mutating func addUserOwnChild(_ reaction: Self) {
        var userOwnChildren = self.userOwnChildren ?? [:]
        var latestChildren = self.latestChildren
        var childrenCounts = self.childrenCounts
        userOwnChildren[reaction.kind, default: []].insert(reaction, at: 0)
        latestChildren[reaction.kind, default: []].insert(reaction, at: 0)
        childrenCounts[reaction.kind, default: 0] += 1
        self.userOwnChildren = userOwnChildren
        self.latestChildren = latestChildren
        self.childrenCounts = childrenCounts
    }
    
    /// Delete an existing user own child reaction for the reaction.
    ///
    /// - Parameter reaction: an existing user own reaction.
    public mutating func removeUserOwnChild(_ reaction: Self) {
        var userOwnChildren = self.userOwnChildren ?? [:]
        var latestChildren = self.latestChildren
        var childrenCounts = self.childrenCounts
        
        if let firstIndex = userOwnChildren[reaction.kind]?.firstIndex(of: reaction) {
            userOwnChildren[reaction.kind, default: []].remove(at: firstIndex)
            self.userOwnChildren = userOwnChildren
            
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
