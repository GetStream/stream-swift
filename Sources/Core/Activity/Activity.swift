//
//  Activity.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 08/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

open class Activity: ActivityProtocol, CustomStringConvertible {
    /// - Note: These reserved words must not be used as field names:
    ///         activity_id, activity, analytics, extra_context, id, is_read, is_seen, origin, score, site_id, to
    private enum CodingKeys: String, CodingKey {
        case id
        case actor
        case verb
        case object
        case target
        case foreignId = "foreign_id"
        case time
        case feedIds = "to"
    }
    
    /// The Stream id of the activity.
    public var id: UUID?
    /// The actor performing the activity.
    public let actor: String
    /// The verb of the activity.
    public let verb: String
    /// The object of the activity.
    public let object: String
    /// The optional target of the activity.
    public let target: String?
    /// A unique ID from your application for this activity. IE: pin:1 or like:300.
    public var foreignId: String?
    /// The optional time of the activity, isoformat. Default is the current time.
    public var time: Date?
    /// An array allows you to specify a list of feeds to which the activity should be copied.
    /// One way to think about it is as the CC functionality of email.
    public var feedIds: FeedIds?
    
    /// Create an activity.
    ///
    /// - Parameters:
    ///     - actor: the actor performing the activity.
    ///     - verb: the verb of the activity.
    ///     - object: the object of the activity.
    ///     - target: the optional target of the activity.
    ///     - foreignId: a unique ID from your application for this activity.
    ///     - time: a time of the activity, isoformat. Default is the current time.
    ///     - feedIds: an array allows you to specify a list of feeds to which the activity should be copied.
    public init(actor: String,
                verb: String,
                object: String,
                target: String? = nil,
                foreignId: String? = nil,
                time: Date? = nil,
                feedIds: FeedIds? = nil) {
        self.actor = actor
        self.verb = verb
        self.object = object
        self.target = target
        self.foreignId = foreignId
        self.time = time
        self.feedIds = feedIds
    }
    
    open var description: String {
        return "\(type(of: self))<\(id?.lowercasedString ?? "<no id>")> foreignId: <\(foreignId ?? "n/a")>, "
            + "\(actor) \(verb) \(object) \(target ?? "") at \(time?.description ?? "<n/a>") to: \(feedIds?.description ?? "[]")"
    }
}
