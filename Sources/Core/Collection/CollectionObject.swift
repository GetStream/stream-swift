//
//  CollectionObject.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A collection object with basic properties of `CollectionObjectProtocol`.
/// You can inherit this class with extra properties on your own `CollectionObject` type.
/// - Note: Please, check the `CollectionObjectProtocol` documentation to implement your User subclass properly.
open class CollectionObject: CollectionObjectProtocol {
    public enum CollectionObjectCodingKeys: String, CodingKey {
        case collectionName = "collection"
        case id
        case created = "created_at"
        case updated = "updated_at"
        case foreignId = "foreign_id"
    }
    
    public enum DataCodingKeys: String, CodingKey {
        case data
    }
    
    public let collectionName: String
    public var id: String?
    public var foreignId: String?
    public var created: Date = Date()
    public var updated: Date = Date()
    
    required public init(collectionName: String, id: String? = nil) {
        self.collectionName = collectionName
        self.id = id
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CollectionObjectCodingKeys.self)
        collectionName = try container.decode(String.self, forKey: .collectionName)
        id = try container.decode(String.self, forKey: .id)
        foreignId = try container.decode(String.self, forKey: .foreignId)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CollectionObjectCodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
    }
    
    public static func missed() -> Self {
        return .init(collectionName: "!missed_reference", id: "!missed_reference")
    }
    
    public var isMissedReference: Bool {
        return collectionName == "!missed_reference" && id == "!missed_reference"
    }
}
