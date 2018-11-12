//
//  Activity.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 08/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

open class Activity: Codable, CustomStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case id
        case actor
        case verb
        case object
        case foreignId = "foreign_id"
        case time
    }
    
    /// The Stream id of the activity.
    let id: UUID
    /// The actor performing the activity.
    let actor: String
    /// The verb of the activity.
    let verb: String
    /// The object of the activity.
    let object: String
    /// A unique ID from your application for this activity. IE: pin:1 or like:300.
    let foreignId: String?
    /// The optional time of the activity, isoformat. Default is the current time.
    let time: Date?
    
    /// An array allows you to specify a list of feeds to which the activity should be copied.
    /// One way to think about it is as the CC functionality of email.
    var feeds: [FeedGroup] = []
    
    /// Create an activity.
    ///
    /// - Parameters:
    ///     - actor: the actor performing the activity.
    ///     - verb: the verb of the activity.
    ///     - object: the object of the activity.
    ///     - foreignId: a unique ID from your application for this activity.
    ///     - time: a time of the activity, isoformat. Default is the current time.
    ///     - toFeeds: an array allows you to specify a list of feeds to which the activity should be copied.
    public init(actor: String, verb: String, object: String, foreignId: String? = nil, time: Date? = nil, toFeeds: [FeedGroup] = []) {
        id = UUID()
        self.actor = actor
        self.verb = verb
        self.object = object
        self.foreignId = foreignId
        self.time = time
        feeds = toFeeds
    }
    
    open var description: String {
        return "\(type(of: self))<\(id)> foreignId: \(foreignId), \(actor) \(verb) \(object) at \(time?.description ?? "n/a")"
    }
}
