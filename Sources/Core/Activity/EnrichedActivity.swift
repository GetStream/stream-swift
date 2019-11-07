//
//  EnrichedActivity.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 08/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// An enriched activity type with actor, object and reaction customizable types.
open class EnrichedActivity<ActorType: Enrichable, ObjectType: Enrichable, ReactionType: ReactionProtocol>: ActivityProtocol {
    /// - Note: These reserved words must not be used as field names:
    ///         activity_id, activity, analytics, extra_context, id, is_read, is_seen, origin, score, site_id, to
    private enum CodingKeys: String, CodingKey {
        case id
        case safeActor = "actor"
        case verb
        case safeObject = "object"
        case foreignId = "foreign_id"
        case time
        case originFeedId = "origin"
        case feedIds = "to"
        case feedGroupId = "group"
        case userOwnReactions = "own_reactions"
        case latestReactions = "latest_reactions"
        case reactionCounts = "reaction_counts"
    }
    
    /// The Stream id of the activity.
    public var id: String = ""
    
    /// A wrapper for the actor performing the activity.
    public let safeActor: MissingReference<ActorType>
    
    /// The actor performing the activity.
    public var actor: ActorType {
        return safeActor.value
    }
    
    /// The verb of the activity.
    public let verb: Verb
    
    /// A wrapper for the object of the activity.
    public let safeObject: MissingReference<ObjectType>
    
    /// The object of the activity.
    public var object: ObjectType {
        return safeObject.value
    }
    
    /// A unique ID from your application for this activity. IE: pin:1 or like:300.
    public var foreignId: String?
    /// The optional time of the activity, isoformat. Default is the current time.
    public var time: Date?
    /// The feed id where the activity was posted.
    public let originFeedId: FeedId?
    /// An array allows you to specify a list of feeds to which the activity should be copied.
    /// One way to think about it is as the CC functionality of email.
    public var feedIds: FeedIds?
    /// An aggregated or notification feed group id.
    public var feedGroupId: String?
    /// Include reactions added by current user to all activities.
    public var userOwnReactions: [ReactionKind: [ReactionType]]?
    /// Include recent reactions to activities.
    public var latestReactions: [ReactionKind: [ReactionType]]?
    /// Include reaction counts to activities.
    public var reactionCounts: [ReactionKind: Int]?
    
    /// Create an activity.
    /// - Parameters:
    ///     - actor: the actor performing the activity.
    ///     - verb: the verb of the activity.
    ///     - object: the object of the activity.
    ///     - foreignId: a unique ID from your application for this activity.
    ///     - time: a time of the activity, isoformat. Default is the current time.
    ///     - feedIds: an array allows you to specify a list of feeds to which the activity should be copied.
    required public init(actor: ActorType,
                         verb: Verb,
                         object: ObjectType,
                         foreignId: String? = nil,
                         time: Date? = nil,
                         feedIds: FeedIds? = nil,
                         originFeedId: FeedId? = nil) {
        safeActor = MissingReference(actor)
        self.verb = verb
        safeObject = MissingReference(object)
        self.foreignId = foreignId
        self.time = time
        self.feedIds = feedIds
        self.originFeedId = originFeedId
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(actor.referenceId, forKey: .safeActor)
        try container.encode(verb, forKey: .verb)
        try container.encode(object.referenceId, forKey: .safeObject)
        try container.encodeIfPresent(foreignId, forKey: .foreignId)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(feedIds, forKey: .feedIds)
    }
    
    public static func missed() -> Self {
        return .init(actor: ActorType.missed(), verb: "", object: ObjectType.missed())
    }
    
    public var isMissedReference: Bool {
        return actor.isMissedReference || object.isMissedReference
    }
}

// MARK: - Description

extension EnrichedActivity: CustomStringConvertible {
    open var description: String {
        return "\(type(of: self))<id: \(id.isEmpty ? "n/a" : id), fid: \(foreignId ?? "n/a")>\n"
            + "\(actor.referenceId) \(verb) \(object.referenceId) at \(time?.description ?? "<n/a>")\n"
            + "feedIds: \(feedIds?.description ?? "[]")\n"
            + "ownReactions: \(userOwnReactions ?? [:])\n"
            + "latestReactions: \(latestReactions ?? [:])\n"
            + "reactionCounts: \(reactionCounts ?? [:])\n"
    }
}

// MARK: - Error Activity

/// An error type of enriching activity properties.
public struct EnrichingActivityError: LocalizedError, Decodable, CustomStringConvertible {
    enum CodingKeys: String, CodingKey {
        case id
        case error
        case referenceId = "reference"
        case referenceType = "reference_type"
    }
    
    /// An object id.
    public let id: String
    /// An error message.
    public let error: String
    /// A reference id of the object.
    public let referenceId: String
    /// A reference type of the object.
    public let referenceType: String
    
    /// Check is the error is a lost reference.
    public var isReferenceNotFound: Bool {
        return error == "ReferenceNotFound"
    }
    
    public var description: String {
        return "Enriching Activity Error \(id): \(error). Reference id: \(referenceId) type: \(referenceType)."
    }
    
    public var localizedDescription: String {
        return description
    }
    
    public var errorDescription: String? {
        return description
    }
}
