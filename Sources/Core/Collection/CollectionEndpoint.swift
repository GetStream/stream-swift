//
//  CollectionEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum CollectionEndpoint {
    case add(_ collectionObject: CollectionObjectProtocol)
    case get(_ collectionName: String, _ collectionObjectId: String)
    case update(_ collectionObject: CollectionObjectProtocol)
    case delete(_ collectionName: String, _ collectionObjectId: String)
}

extension CollectionEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case .add(let collectionObject):
            return "collections/\(collectionObject.collectionName)/"
        case .get(let collectionName, let objectId), .delete(let collectionName, let objectId):
            return "collections/\(collectionName)/\(objectId)/"
        case .update(let collectionObject):
            return "collections/\(collectionObject.collectionName)/\(collectionObject.id ?? "")/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .add:
            return .post
        case .get:
            return .get
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .add(let collectionObject):
            return .requestJSONEncodable(collectionObject)
        case .get, .delete:
            return .requestPlain
        case .update(let collectionObject):
            return .requestJSONEncodable(collectionObject)
        }
    }
    
    var sampleJSON: String {
        switch self {
        case .add, .get:
            return """
            {"duration":"4.15ms","id":"123","collection":"food","foreign_id":"food:123","data":{ "name": "Burger" },"created_at":"2018-12-24T13:35:02.290307Z","updated_at":"2018-12-24T13:35:02.290307Z"}
            """
        case .update:
            return """
            {"duration":"4.15ms","id":"123","collection":"food","foreign_id":"food:123","data":{ "name": "Burger2" },"created_at":"2018-12-24T13:35:02.290307Z","updated_at":"2018-12-24T13:35:02.290307Z"}
            """
        case .delete:
            return "{}"
        }
    }
}
