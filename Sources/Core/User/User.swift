//
//  User.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// An User class with basic properties of `UserProtocol`.
/// You can inherit this class with extra properties on your own User type.
/// - Note: Please, check the `UserProtocol` documentation to implement your User subclass properly.
open class User: UserProtocol {
    private enum UserCodingKeys: String, CodingKey {
        case id
        case created = "created_at"
        case updated = "updated_at"
        case followersCount = "followers_count"
        case followingCount = "following_count"
    }
    
    /// Coding keys for extra user properties.
    public enum DataCodingKeys: String, CodingKey {
        case data
    }
    
    /// A user id.
    public let id: String
    /// An user created date.
    public var created: Date = Date()
    /// An user updated date.
    public var updated: Date = Date()
    /// A number of followers.
    public var followersCount: Int?
    /// A number of followings.
    public var followingCount: Int?
    
    /// Create a user with a given id.
    ///
    /// - Parameter id: a user id.
    required public init(id: String) {
        self.id = id
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: UserCodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    public static func missed() -> Self {
        return .init(id: "!missed_reference")
    }
    
    public var isMissedReference: Bool {
        return id == "!missed_reference"
    }
}

extension User: Equatable {
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs === rhs || (!lhs.id.isEmpty && lhs.id == rhs.id)
    }
}
