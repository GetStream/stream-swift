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
    public let user: U
    public let kind: ReactionKind
    public let created: Date
    public let updated: Date?
    public let data: T
    public var parentId: String?
    public let childrenCounts: [ReactionKind: Int]
    private var latestChildrenContainer: KeyedDecodingContainer<Reaction<T, U>.ChildrenCodingKeys>?
    private var dataContainer: KeyedDecodingContainer<Reaction<T, U>.DataCodingKeys>?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        activityId = try container.decode(String.self, forKey: .activityId)
        user = try container.decode(U.self, forKey: .user)
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
        
        if T.self is EmptyReactionExtraData.Type {
            self.dataContainer = dataContainer
        }
    }
    
    public func encode(to encoder: Encoder) throws {}
    
    /// Decode an extra data with a specific type of `ReactionExtraDataProtocol`.
    ///
    /// - Note: It useful when you need to get extra fields from the reaction,
    ///         but by default it was decoded as an `EmptyReactionExtraData`.
    /// - Parameter type: the `ReactionExtraDataProtocol` type of the specific reaction extra data.
    /// - Returns: a specific extra data object.
    public func data<T: ReactionExtraDataProtocol>(typeOf: T.Type) -> T? {
        if data is T {
            return data as? T
        }
        
        if let dataContainer = dataContainer, let data = try? dataContainer.decode(T.self, forKey: .data) {
            return data
        }
        
        return nil
    }
    
    public func latestChildren(kindOf kind: ReactionKind) -> [DefaultReaction] {
        return latestChildren(kindOf: kind, extraDataTypeOf: EmptyReactionExtraData.self, userTypeOf: User.self)
    }
    
    public func latestChildren<T: ReactionExtraDataProtocol, U: UserProtocol>(kindOf kind: ReactionKind,
                                                                              extraDataTypeOf: T.Type,
                                                                              userTypeOf: U.Type) -> [Reaction<T, U>] {
        if let container = latestChildrenContainer,
            let latestChildren = try? container.decode([Reaction<T, U>].self, forKey: .init(kind: kind)) {
            return latestChildren
        }
        
        return []
    }
    
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
