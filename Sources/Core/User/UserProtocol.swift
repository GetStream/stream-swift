//
//  UserProtocol.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A user protocol.
///
/// This protocol describe basic properties. You can extend them with own type,
/// but you have to implement `Encodable` and `Decodable` protocols in a specific way:
/// - the protocol properties present on the root level of the user structure,
/// - additinal properties should be encoded/decoded in the nested `data` container.
///
/// Here is an example of a JSON responce:
/// ```
/// {
///     "id": "alice123",
///     "data": { "name": "Alice" },
///     "created_at": "2018-12-17T15:23:26.591179Z",
///     "updated_at": "2018-12-17T15:23:26.591179Z",
///     "duration":"0.45ms"
/// }
/// ```
///
/// You can extend our opened `User` class for the default protocol properties.
///
/// Example with custom properties:
/// ```
///     final class User: GetStream.User {
///         private enum CodingKeys: String, CodingKey {
///             case name
///         }
///
///         var name: String
///
///         init(id: String, name: String) {
///             self.name = name
///             super.init(id: id)
///         }
///
///         required init(from decoder: Decoder) throws {
///             let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
///             let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
///             name = try container.decode(String.self, forKey: .name)
///             try super.init(from: decoder)
///         }
///
///         override func encode(to encoder: Encoder) throws {
///             var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
///             var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
///             try container.encode(name, forKey: .name)
///             try super.encode(to: encoder)
///         }
///     }
/// ```
///
/// Here is an example how to use a custom User type:
/// ```
///     let user = User(id: "alice123", name: "Alice")
///     client.create(user: user) {
///         // Let's try retrieve details of the created user and use custom properties.
///         client.get(typeOf: User.self, userId: "alice123") {
///             let user = try? $0.get() // here the user is a custom User type.
///             print(user?.name) // it will print "Alice".
///         }
///     }
/// ```
public protocol UserProtocol: Enrichable {
    /// A user Id. Must not be empty or longer than 255 characters.
    var id: String { get }
    /// When the user was created.
    var created: Date { get }
    /// When the user was last updated.
    var updated: Date { get }
    /// Number of users that follow this user.
    var followersCount: Int? { get }
    /// Number of users this user is following.
    var followingCount: Int? { get }
}

// MARK: - Enrichable

extension UserProtocol {
    /// A referenceId for the enrichability.
    public var referenceId: String {
        return "SU:\(id)"
    }
}

// MARK: - Shared User

extension UserProtocol {
    public static var current: Self? {
        return Client.shared.currentUser as? Self
    }
}
