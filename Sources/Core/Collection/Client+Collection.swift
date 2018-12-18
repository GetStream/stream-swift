//
//  Client+Collection.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

public typealias CollectionObjectCompletion<T: CollectionObjectProtocol> = (_ result: Result<T, ClientError>) -> Void

extension Client {
    
    /// Add a collection object to the collection with a given name.
    ///
    /// - Parameters:
    ///     - collectionObject: a collection object.
    ///     - completion: a completion block with a collection object that was added.
    @discardableResult
    public func add<T: CollectionObjectProtocol>(collectionObject: T,
                                                 completion: @escaping CollectionObjectCompletion<T>) -> Cancellable {
        return request(endpoint: CollectionEndpoint.add(collectionObject)) {
            $0.parse(completion)
        }
    }
    
    /// Retreive a collection object from the collection by the collection object id.
    ///
    /// - Parameters:
    ///     - typeOf: a type of a collection object type that conformed to `CollectionObjectProtocol`.
    ///     - collectionName: a collection name.
    ///     - collectionObjectId: a collection object id.
    ///     - completion: a completion block with a requested collection object.
    @discardableResult
    public func get<T: CollectionObjectProtocol>(typeOf: T.Type,
                                                 collectionName: String,
                                                 collectionObjectId: String,
                                                 completion: @escaping CollectionObjectCompletion<T>) -> Cancellable {
        return request(endpoint: CollectionEndpoint.get(collectionName, collectionObjectId)) {
            $0.parse(completion)
        }
    }
    
    /// Update a collection object.
    ///
    /// - Parameters:
    ///     - collectionObject: a collection object.
    ///     - completion: a completion block with an updated collection object.
    @discardableResult
    public func update<T: CollectionObjectProtocol>(collectionObject: T,
                                                    completion: @escaping CollectionObjectCompletion<T>) -> Cancellable {
        return request(endpoint: CollectionEndpoint.update(collectionObject)) {
            $0.parse(completion)
        }
    }
    
    @discardableResult
    public func delete<T: CollectionObjectProtocol>(collectionObject: T,
                                                    completion: @escaping StatusCodeCompletion) -> Cancellable {
        guard let objectId = collectionObject.id else {
            completion(.failure(.jsonInvalid))
            return SimpleCancellable()
        }
        
        return delete(collectionName: collectionObject.collectionName, collectionObjectId: objectId, completion: completion)
    }

    /// Delete a collection object.
    ///
    /// - Parameters:
    ///     - collectionName: a collection name.
    ///     - collectionObjectId: a collection object id.
    ///     - completion: a completion block with a response status code.
    @discardableResult
    public func delete(collectionName: String,
                       collectionObjectId: String,
                       completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: CollectionEndpoint.delete(collectionName, collectionObjectId)) {
            $0.parseStatusCode(completion)
        }
    }
}
