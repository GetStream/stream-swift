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

public typealias ReactionCompletion<T: ReactionExtraDataProtocol> = (_ result: Result<Reaction<T>, ClientError>) -> Void
public typealias ReactionsCompletion<T: ReactionExtraDataProtocol> = (_ result: Result<Reactions<T>, ClientError>) -> Void

extension Result where Value == Response, Error == ClientError {
    
    /// Parse the result with a given reaction completion block.
    func parseReaction<T: ReactionExtraDataProtocol>(_ completion: @escaping ReactionCompletion<T>) {
        parse(block: {
            let response = try dematerialize()
            let reaction = try JSONDecoder.stream.decode(Reaction<T>.self, from: response.data)
            completion(.success(reaction))
        }, catch: {
            completion(.failure($0))
        })
    }
    
    /// Parse the result with a given reaction completion block.
    func parseReactions<T: ReactionExtraDataProtocol>(_ completion: @escaping ReactionsCompletion<T>) {
        parse(block: {
            let response = try dematerialize()
            let reactions = try JSONDecoder.stream.decode(Reactions<T>.self, from: response.data)
            completion(.success(reactions))
        }, catch: {
            completion(.failure($0))
        })
    }
}
