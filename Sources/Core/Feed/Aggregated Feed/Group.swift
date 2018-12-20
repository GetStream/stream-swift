//
//  Group.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

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
    
    public let id: UUID
    public let group: String
    public let verb: String
    public let activitiesCount: Int
    public let actorsCount: Int
    public let created: Date
    public let updated: Date
    public let activities: [T]
}
