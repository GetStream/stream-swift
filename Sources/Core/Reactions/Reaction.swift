//
//  Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

// MARK: - Reaction Kind & Extra Data

public typealias ReactionKind = String
public typealias ReactionExtraDataProtocol = Codable

extension ReactionKind {
    static let like = "like"
    static let comment = "comment"
}

public struct ReactionNoExtraData: ReactionExtraDataProtocol {
    static let shared = ReactionNoExtraData()
}

// MARK: - Reaction

public struct Reaction<T: ReactionExtraDataProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case activityId = "activity_id"
        case userId = "user_id"
        case kind
        case created = "created_at"
        case updated = "updated_at"
        case data
        case parentId = "parent"
        case latestChildren = "latest_children"
        case childrenCounts = "children_counts"
    }
    
    private struct ChildrenCodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String
        
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = String(intValue)
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init(kind: ReactionKind) {
            stringValue = kind
        }
    }
    
    public let id: UUID
    public let activityId: UUID
    public let userId: String
    public let kind: ReactionKind
    public let created: Date
    public let updated: Date?
    public let data: T
    public var parentId: UUID?
    public let childrenCounts: [ReactionKind: Int]
    private var container: KeyedDecodingContainer<Reaction<T>.ChildrenCodingKeys>?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        activityId = try container.decode(UUID.self, forKey: .activityId)
        userId = try container.decode(String.self, forKey: .userId)
        kind = try container.decode(String.self, forKey: .kind)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        data = try container.decode(T.self, forKey: .data)
        childrenCounts = try container.decode([ReactionKind: Int].self, forKey: .childrenCounts)

        let parentIdString = try container.decode(String.self, forKey: .parentId)
        
        if !parentIdString.isEmpty {
            parentId = UUID(uuidString: parentIdString)
        }
        
        if !childrenCounts.isEmpty {
            self.container = try? container.nestedContainer(keyedBy: ChildrenCodingKeys.self, forKey: .latestChildren)
        }
    }
    
    public func latestChildren(kindOf kind: ReactionKind) -> [Reaction<ReactionNoExtraData>] {
        return latestChildren(kindOf: kind, extraDataTypeOf: ReactionNoExtraData.self)
    }
    
    public func latestChildren<U: ReactionExtraDataProtocol>(kindOf kind: ReactionKind, extraDataTypeOf: U.Type) -> [Reaction<U>] {
        guard let container = container else {
            return []
        }
        
        let latestChildren = try? container.decode([Reaction<U>].self, forKey: .init(kind: kind))
        return latestChildren ?? []
    }
}
