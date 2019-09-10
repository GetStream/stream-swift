//
//  Client+Collection.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A collection object completion block.
public typealias CollectionObjectCompletion<T: CollectionObjectProtocol> = (_ result: Result<T, ClientError>) -> Void

// MARK: - Client Collections

extension Client {
    
    /// Add a collection object to the collection with a given name.
    ///
    /// - Parameters:
    ///     - collectionObject: a collection object.
    ///     - completion: a completion block with a collection object that was added.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: CollectionObjectProtocol>(collectionObject: T,
                                                 completion: @escaping CollectionObjectCompletion<T>) -> Cancellable {
        return request(endpoint: CollectionEndpoint.add(collectionObject)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Retreive a collection object from the collection by the collection object id.
    ///
    /// - Parameters:
    ///     - typeOf: a type of a custom collection object type that conformed to `CollectionObjectProtocol`.
    ///     - collectionName: a collection name.
    ///     - collectionObjectId: a collection object id.
    ///     - completion: a completion block with a requested collection object.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get<T: CollectionObjectProtocol>(typeOf: T.Type,
                                                 collectionName: String,
                                                 collectionObjectId: String,
                                                 completion: @escaping CollectionObjectCompletion<T>) -> Cancellable {
        return request(endpoint: CollectionEndpoint.get(collectionName, collectionObjectId)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Update a collection object.
    ///
    /// - Parameters:
    ///     - collectionObject: a collection object.
    ///     - completion: a completion block with an updated collection object.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func update<T: CollectionObjectProtocol>(collectionObject: T,
                                                    completion: @escaping CollectionObjectCompletion<T>) -> Cancellable {
        return request(endpoint: CollectionEndpoint.update(collectionObject)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Delete a collection object.
    ///
    /// - Parameters:
    ///     - collectionObject: a collection object.
    ///     - completion: a completion block with a response status code.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func delete<T: CollectionObjectProtocol>(collectionObject: T,
                                                    completion: @escaping StatusCodeCompletion) -> Cancellable {
        guard let objectId = collectionObject.id else {
            callbackQueue.async { completion(.failure(.jsonInvalid("Collection Object id is empty"))) }
            return SimpleCancellable()
        }
        
        return delete(collectionName: collectionObject.collectionName, collectionObjectId: objectId, completion: completion)
    }
    
    /// Delete a collection object with a given collection name and object id.
    ///
    /// - Parameters:
    ///     - collectionName: a collection name.
    ///     - collectionObjectId: a collection object id.
    ///     - completion: a completion block with a response status code.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func delete(collectionName: String,
                       collectionObjectId: String,
                       completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: CollectionEndpoint.delete(collectionName, collectionObjectId)) { [weak self] result in
            if let self = self {
                result.parseStatusCode(self.callbackQueue, completion)
            }
        }
    }
}
