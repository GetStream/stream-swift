//
//  Group.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// An aggregated group type.
public class Group<T: ActivityProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case group
        case verb
        case activitiesCount = "activity_count"
        case actorsCount = "actor_count"
        case created = "created_at"
        case updated = "updated_at"
        case activities
    }
    
    /// A group id.
    public let id: String
    /// A group name.
    public let group: String
    /// A verb.
    public let verb: Verb
    /// A number of activities in the group.
    public let activitiesCount: Int
    /// A number of actors in the group.
    public let actorsCount: Int
    /// A created date.
    public let created: Date
    /// An updated date.
    public let updated: Date
    /// A list of activities.
    public let activities: [T]
}
