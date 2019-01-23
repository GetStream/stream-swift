//
//  ActivityProtocol.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 13/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A verb type of the Activity.
/// - Note: Verb type is useful for the making of static verb strings in the extension of the Verb type.
public typealias Verb = String

/// A protocol for the Activity type.
public protocol ActivityProtocol: Enrichable {
    associatedtype ActorType = Enrichable
    associatedtype ObjectType = Enrichable
    associatedtype TargetType = Enrichable
    
    /// The Stream id of the activity.
    var id: String { get set }
    /// The actor performing the activity.
    var actor: ActorType { get }
    /// The verb of the activity.
    var verb: Verb { get }
    /// The object of the activity.
    /// - Note: It shouldn't be empty.
    var object: ObjectType { get }
    /// The optional target of the activity.
    var target: TargetType? { get }
    /// A unique ID from your application for this activity. IE: pin:1 or like:300.
    var foreignId: String? { get set }
    /// The optional time of the activity, isoformat. Default is the current time.
    var time: Date? { get set }
    /// An array allows you to specify a list of feeds to which the activity should be copied.
    /// One way to think about it is as the CC functionality of email.
    var feedIds: FeedIds? { get set }
    /// Include reactions added by current user to all activities.
    var ownReactions: [ReactionKind: [Reaction<ReactionNoExtraData>]]? { get set }
    /// Include recent reactions to activities.
    var latestReactions: [ReactionKind: [Reaction<ReactionNoExtraData>]]? { get set }
    /// Include reaction counts to activities.
    var reactionCounts: [ReactionKind: Int]? { get set }
}

// MARK: - Enrichable

extension ActivityProtocol {
    /// The activity is enrichable and here is a referenceId by default.
    /// For example, in case when you need to make a repost activity where `object` would be the original activity.
    public var referenceId: String {
        return "SA:\(id)"
    }
}

// MARK: - Own reactions

extension ActivityProtocol {
    
    /// Update the activity with a new own reaction.
    ///
    /// - Parameter reaction: a new own reaction.
    public mutating func addOwnReaction(_ reaction: Reaction<ReactionNoExtraData>) {
        var ownReactions = self.ownReactions ?? [:]
        var latestReactions = self.latestReactions ?? [:]
        var reactionCounts = self.reactionCounts ?? [:]
        ownReactions[reaction.kind, default: []].append(reaction)
        latestReactions[reaction.kind, default: []].append(reaction)
        reactionCounts[reaction.kind, default: 0] += 1
        self.ownReactions = ownReactions
        self.latestReactions = latestReactions
        self.reactionCounts = reactionCounts
    }
    
    /// Delete an existing own reaction for the activity.
    ///
    /// - Parameter reaction: an existing own reaction.
    public mutating func deleteOwnReaction(_ reaction: Reaction<ReactionNoExtraData>) {
        var ownReactions = self.ownReactions ?? [:]
        var latestReactions = self.latestReactions ?? [:]
        var reactionCounts = self.reactionCounts ?? [:]
        
        if let firstIndex = ownReactions[reaction.kind]?.firstIndex(of: reaction) {
            ownReactions[reaction.kind, default: []].remove(at: firstIndex)
            self.ownReactions = ownReactions
            
            if let firstIndex = latestReactions[reaction.kind]?.firstIndex(of: reaction) {
                latestReactions[reaction.kind, default: []].remove(at: firstIndex)
                self.latestReactions = latestReactions
            }
            
            if let count = reactionCounts[reaction.kind], count > 0 {
                reactionCounts[reaction.kind, default: 0] = count - 1
                self.reactionCounts = reactionCounts
            }
        }
    }
}
