//
//  Result+ParseReaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

public typealias ReactionCompletion<T: ReactionExtraDataProtocol,
                                    U: UserProtocol> = (_ result: Result<Reaction<T, U>, ClientError>) -> Void

public typealias ReactionsCompletion<T: ReactionExtraDataProtocol,
                                     U: UserProtocol> = (_ result: Result<Reactions<T, U>, ClientError>) -> Void

public typealias DefaultReactionCompletion = ReactionCompletion<EmptyReactionExtraData, User>
public typealias DefaultReactionsCompletion = ReactionsCompletion<EmptyReactionExtraData, User>

// MARK: - Result Reactions Parsing

extension Result where Value == Moya.Response, Error == ClientError {
    
    /// Parse the result with a given reaction completion block.
    func parseReaction<T: ReactionExtraDataProtocol, U: UserProtocol>(_ callbackQueue: DispatchQueue,
                                                                      _ completion: @escaping ReactionCompletion<T, U>) {
        parse(block: {
            let response = try get()
            let reaction = try JSONDecoder.stream.decode(Reaction<T, U>.self, from: response.data)
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
            let reactions = try JSONDecoder.stream.decode(Reactions<T, U>.self, from: response.data)
            callbackQueue.async { completion(.success(reactions)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
}
