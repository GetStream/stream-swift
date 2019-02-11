//
//  Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias ReactionKind = String
public typealias ReactionExtraDataProtocol = Codable
public typealias DefaultReaction = Reaction<EmptyReactionExtraData, User>

public protocol ReactionProtocol: Codable {
    var id: String { get }
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
    
    public let id: String
    public let activityId: String
    public let user: U
    public let kind: ReactionKind
    public let created: Date
    public let updated: Date?
    public let data: T
    public var parentId: String?
    public let latestChildren: [ReactionKind: [Reaction<T, U>]]
    public let childrenCounts: [ReactionKind: Int]
    
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
        latestChildren = try container.decode([ReactionKind: [Reaction<T, U>]].self, forKey: .latestChildren)
        childrenCounts = try container.decode([ReactionKind: Int].self, forKey: .childrenCounts)
    }
    
    public func encode(to encoder: Encoder) throws {}
    
    public static func == (lhs: Reaction<T, U>, rhs: Reaction<T, U>) -> Bool {
        return !lhs.id.isEmpty && lhs.id == rhs.id
    }
}

// MARK: - Reaction No Extra Data

public struct EmptyReactionExtraData: ReactionExtraDataProtocol, Equatable {
    public static let shared = EmptyReactionExtraData()
}

// MARK: - Reaction Kind

extension ReactionKind {
    public static let like = "like"
    public static let comment = "comment"
}
