//
//  Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct ReactionNoExtraData: ReactionExtraDataProtocol {
    static let shared = ReactionNoExtraData()
}

public struct Reaction<T: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case activityId = "activity_id"
        case userId = "user_id"
        case kind
        case created = "created_at"
        case updated = "updated_at"
        case data
        case parentId = "parent"
    }
    
    public let id: UUID
    public let activityId: UUID
    public let userId: String
    public let kind: ReactionKind
    public let created: Date
    public let updated: Date?
    public let data: T
    public var parentId: UUID?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        activityId = try container.decode(UUID.self, forKey: .activityId)
        userId = try container.decode(String.self, forKey: .userId)
        kind = try container.decode(String.self, forKey: .kind)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        data = try container.decode(T.self, forKey: .data)
        let parentIdString = try container.decode(String.self, forKey: .parentId)
        
        if !parentIdString.isEmpty {
            parentId = UUID(uuidString: parentIdString)
        }
    }
}
