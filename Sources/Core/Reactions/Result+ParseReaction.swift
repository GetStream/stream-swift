//
//  Result+ParseReaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

/// A reaction completion block.
public typealias ReactionCompletion<T: ReactionExtraDataProtocol,
                                    U: UserProtocol> = (_ result: Result<Reaction<T, U>, ClientError>) -> Void

/// A reactions completion block.
public typealias ReactionsCompletion<T: ReactionExtraDataProtocol,
                                     U: UserProtocol> = (_ result: Result<Reactions<T, U>, ClientError>) -> Void

/// A default reaction completion block.
public typealias DefaultReactionCompletion = ReactionCompletion<EmptyReactionExtraData, User>
/// A default reactions completion block.
public typealias DefaultReactionsCompletion = ReactionsCompletion<EmptyReactionExtraData, User>

// MARK: - Result Reactions Parsing

extension Result where Success == Moya.Response, Failure == ClientError {
    
    /// Parse the result with a given reaction completion block.
    func parseReaction<T: ReactionExtraDataProtocol, U: UserProtocol>(_ callbackQueue: DispatchQueue,
                                                                      _ completion: @escaping ReactionCompletion<T, U>) {
        parse(block: {
            let response = try get()
            let reaction = try JSONDecoder.default.decode(Reaction<T, U>.self, from: response.data)
            callbackQueue.async { completion(.success(reaction)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
    
    /// Parse the result with a given reaction completion block.
    func parseReactions<T: ReactionExtraDataProtocol, U: UserProtocol>(_ callbackQueue: DispatchQueue,
                                                                       _ completion: @escaping ReactionsCompletion<T, U>) {
        parse(block: {
            let response = try get()
            let reactions = try JSONDecoder.default.decode(Reactions<T, U>.self, from: response.data)
            callbackQueue.async { completion(.success(reactions)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
}
