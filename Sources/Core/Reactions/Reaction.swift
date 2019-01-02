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

public struct ReactionNoExtraData: ReactionExtraDataProtocol, Equatable {
    static let shared = ReactionNoExtraData()
}

// MARK: - Reaction

public struct Reaction<T: ReactionExtraDataProtocol>: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case activityId = "activity_id"
        case userId = "user_id"
        case kind
        case created = "created_at"
        case updated = "updated_at"
        case parentId = "parent"
        case latestChildren = "latest_children"
        case childrenCounts = "children_counts"
    }
    
    private enum DataCodingKeys: String, CodingKey {
        case data
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
    public let userId: String
    public let kind: ReactionKind
    public let created: Date
    public let updated: Date?
    public let data: T
    public var parentId: String?
    public let childrenCounts: [ReactionKind: Int]
    private var latestChildrenContainer: KeyedDecodingContainer<Reaction<T>.ChildrenCodingKeys>?
    private var dataContainer: KeyedDecodingContainer<Reaction<T>.DataCodingKeys>?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        activityId = try container.decode(String.self, forKey: .activityId)
        userId = try container.decode(String.self, forKey: .userId)
        kind = try container.decode(String.self, forKey: .kind)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        childrenCounts = try container.decode([ReactionKind: Int].self, forKey: .childrenCounts)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        
        if !childrenCounts.isEmpty {
            latestChildrenContainer = try? container.nestedContainer(keyedBy: ChildrenCodingKeys.self, forKey: .latestChildren)
        }
        
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        data = try dataContainer.decode(T.self, forKey: .data)
        
        if T.self is ReactionNoExtraData.Type {
            self.dataContainer = dataContainer
        }
    }
    
    public func encode(to encoder: Encoder) throws {}
    
    public func data<V: ReactionExtraDataProtocol>(typeOf: V.Type) -> V? {
        if data is V {
            return data as? V
        }
        
        if let dataContainer = dataContainer, let data = try? dataContainer.decode(V.self, forKey: .data) {
            return data
        }
        
        return nil
    }
    
    public func latestChildren(kindOf kind: ReactionKind) -> [Reaction<ReactionNoExtraData>] {
        return latestChildren(kindOf: kind, extraDataTypeOf: ReactionNoExtraData.self)
    }
    
    public func latestChildren<U: ReactionExtraDataProtocol>(kindOf kind: ReactionKind, extraDataTypeOf: U.Type) -> [Reaction<U>] {
        if let container = latestChildrenContainer,
            let latestChildren = try? container.decode([Reaction<U>].self, forKey: .init(kind: kind)) {
            return latestChildren
        }
        
        return []
    }
}
