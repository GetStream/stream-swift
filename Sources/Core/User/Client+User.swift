//
//  Client+User.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

public typealias UserCompletion<T: UserProtocol> = (_ result: Result<T, ClientError>) -> Void

// MARK: - Client User

extension Client {
    
    /// Create or add an user with a given data.
    ///
    /// - Parameters:
    ///     - user: an user of type `UserProtocol`, where `id` must not be empty or longer than 255 characters.
    ///     - getOrCreate: if true, if a user with the same `id` already exists, it will be returned.
    ///                    Otherwise, the endpoint will return `409 Conflict`. Default: true.
    ///     - completion: a completion block with an user object of the `UserProtocol` in the `Result`.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func create<T: UserProtocol>(user: T, getOrCreate: Bool = true, completion: @escaping UserCompletion<T>) -> Cancellable {
        return request(endpoint: UserEndpoint.create(user, getOrCreate)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Get an user by default `User` type with a given `userId`.
    ///
    /// - Parameters:
    ///     - userId: an user id string.
    ///     - withFollowCounts: if true, the followingCount and followersCount will be included in the response. Default: false.
    ///     - completion: a completion block with an user object of the `UserProtocol` in the `Result`.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get(userId: String, withFollowCounts: Bool = false, completion: @escaping UserCompletion<User>) -> Cancellable {
        return get(typeOf: User.self, userId: userId, completion: completion)
    }
    
    /// Get an user with a given `userId`.
    ///
    /// - Parameters:
    ///     - typeOf: a type of an user type that conformed to `UserProtocol`.
    ///     - userId: an user id string.
    ///     - withFollowCounts: if true, the followingCount and followersCount will be included in the response. Default: false.
    ///     - completion: a completion block with an user object of the `UserProtocol` in the `Result`.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get<T: UserProtocol>(typeOf: T.Type,
                                     userId: String,
                                     withFollowCounts: Bool = false,
                                     completion: @escaping UserCompletion<T>) -> Cancellable {
        return request(endpoint: UserEndpoint.get(userId, withFollowCounts)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Update the user data.
    ///
    /// - Parameters:
    ///     - user: the user of type `UserProtocol`, where `id` must not be empty or longer than 255 characters.
    ///     - completion: a completion block with an user object of the `UserProtocol` in the `Result`.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func update<T: UserProtocol>(user: T, completion: @escaping UserCompletion<T>) -> Cancellable {
        return request(endpoint: UserEndpoint.update(user)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Delete a user with a given `userId`.
    ///
    /// - Parameters:
    ///     - userId: an user id string.
    ///     - completion: a completion block with a response status code.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func delete(userId: String, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: UserEndpoint.delete(userId)) { [weak self] result in
            if let self = self {
                result.parseStatusCode(self.callbackQueue, completion)
            }
        }
    }
}
