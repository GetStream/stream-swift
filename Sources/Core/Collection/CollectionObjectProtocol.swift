//
//  CollectionObjectProtocol.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A collection object protocol.
///
/// This protocol describe basic properties. You can extend them with own type,
/// but you have to implement `Encodable` and `Decodable` protocols in a specific way:
/// - the protocol properties present on the root level of the user structure,
/// - additinal properties should be encoded/decoded in the nested `data` container.
///
/// Here is an example of a JSON responce:
/// ```
/// {
///     "id": "burger",
///     "collection": "food",
///     "foreign_id":"food:burger"
///     "data": { "name": "Burger" },
///     "created_at": "2018-12-17T15:23:26.591179Z",
///     "updated_at": "2018-12-17T15:23:26.591179Z",
///     "duration":"0.45ms"
/// }
/// ```
///
/// You can extend our opened `CollectionObject` class for the default protocol properties.
///
/// Example with custom properties:
/// ```
///     final class Food: CollectionObject {
///         private enum CodingKeys: String, CodingKey {
///             case name
///         }
///
///         var name: String
///
///         init(name: String, id: String? = nil) {
///             self.name = name
///             super.init(collectionName: "food", id: id)
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
public protocol CollectionObjectProtocol: Enrichable {
    /// A collection name.
    var collectionName: String { get }
    /// A collection object id.
    var id: String? { get }
    /// An foreign id of the collection object. The format is `<collectionName>:<id>`.
    var foreignId: String? { get }
    /// When the collection object was created.
    var created: Date { get }
    /// When the collection object was last updated.
    var updated: Date { get }
}

// MARK: - Enrichable

extension CollectionObjectProtocol {
    public var referenceId: String {
        guard let id = id, !id.isEmpty else {
            return "SO:\(collectionName)"
        }
        
        return "SO:\(collectionName):\(id)"
    }
}
