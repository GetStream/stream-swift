//
//  Client+Setup.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 09/12/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Faye

// MARK: - Client User Setup

extension Client {
    
    /// Setup the current user with a default `User` type.
    ///
    /// - Parameters:
    ///     - completion: a completion block with an `User` object in the `Result`.
    ///     - token: the user Client token.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func setupUser(token: Token, completion: @escaping UserCompletion<User>) -> Cancellable {
        parseToken(token)
        return setupUser(User(id: currentUserId ?? ""), token: token, completion: completion)
    }
    
    /// Setup the current user with a custom `User` type.
    ///
    /// - Parameters:
    ///     - user: a custom user object.
    ///     - token: the user Client token.
    ///     - completion: a completion block with a custom `User` object in the `Result`.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func setupUser<T: UserProtocol>(_ user: T, token: Token, completion: @escaping UserCompletion<T>) -> Cancellable {
        Client.fayeClient.disconnect()
        parseToken(token)
        
        guard let currentUserId = currentUserId else {
            let error = ClientError.clientSetup("The current user id is empty")
            logger?.log(error.description)
            completion(.failure(error))
            return SimpleCancellable()
        }
        
        guard user.id == currentUserId else {
            let error = ClientError.clientSetup("The current user id is not the same as in Token")
            logger?.log(error.description)
            completion(.failure(error))
            return SimpleCancellable()
        }
        
        ClientLogger.logger("👤", "", "User id: \(currentUserId)")
        ClientLogger.logger("🀄️", "", "Token: \(token)")
        
        return create(user: user) { [weak self] result in
            if let user = try? result.get() {
                Client.shared.currentUser = user
                self?.logger?.log("👤 The current user was setupped with id: \(user.id)")
            } else if let error = result.error {
                self?.logger?.log(error.localizedDescription)
            }
            
            completion(result)
        }
    }
    
    private func parseToken(_ token: Token) {
        self.token = ""
        currentUserId = nil
        
        if token.isEmpty {
            return
        }
        
        if let userId = token.userId {
            self.token = token
            currentUserId = userId
        }
    }
}
