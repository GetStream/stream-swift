//
//  UserProtocol.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public protocol UserProtocol: Codable {
    /// User ID. Must not be empty or longer than 255 characters.
    var id: String { get }
    /// When the user was created.
    var created: Date? { get }
    /// When the user was last updated.
    var updated: Date? { get }
    /// Number of users that follow this user.
    var followersCount: Int? { get }
    /// Number of users this user is following.
    var followingCount: Int? { get }
}

/// A generic Stream user class.
open class User: UserProtocol {
    public enum UserCodingKeys: String, CodingKey {
        case id
        case created = "created_at"
        case updated = "updated_at"
        case followersCount = "followers_count"
        case followingCount = "following_count"
    }
    
    public enum DataCodingKeys: String, CodingKey {
        case data
    }
    
    public let id: String
    public var created: Date?
    public var updated: Date?
    public var followersCount: Int?
    public var followingCount: Int?
    
    public init(id: String) {
        self.id = id
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        created = try container.decodeIfPresent(Date.self, forKey: .created)
        updated = try container.decodeIfPresent(Date.self, forKey: .updated)
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount)
    }
    
    open func encode(to encoder: Encoder) throws {
        var idContainer = encoder.container(keyedBy: UserCodingKeys.self)
        try idContainer.encode(id, forKey: .id)
    }
}
