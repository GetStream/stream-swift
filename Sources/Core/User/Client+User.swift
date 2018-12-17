//
//  Client+User.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

extension Client {
    
    
    /// Create or add a user with a given data.
    ///
    /// - Parameters:
    ///     - user: a user of type `UserProtocol`, where `id` must not be empty or longer than 255 characters.
    ///     - getOrCreate: If true, if a user with the same `id` already exists, it will be returned.
    ///                    Otherwise, the endpoint will return `409 Conflict`.
    @discardableResult
    public func create(user: UserProtocol, getOrCreate: Bool = true) -> Cancellable {
        return request(endpoint: UserEndpoint.create(user, getOrCreate), completion: { result in
            print(result)
        })
    }
}
