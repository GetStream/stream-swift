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

extension Result where Value == Response, Error == ClientError {
    
    /// Parse the result with a given reaction completion block.
    func parseReaction<T: ReactionExtraDataProtocol>(completion: @escaping ReactionCompletion<T>) {
        do {
            let response = try dematerialize()
            let reaction = try JSONDecoder.stream.decode(Reaction<T>.self, from: response.data)
            completion(.success(reaction))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error.localizedDescription)))
        }
    }
    
    /// Parse the result with a given reaction completion block.
    func parseReactions<T: ReactionExtraDataProtocol>(completion: @escaping ReactionsCompletion<T>) {
        do {
            let response = try dematerialize()
            let reactions = try JSONDecoder.stream.decode(Reactions<T>.self, from: response.data)
            completion(.success(reactions))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error.localizedDescription)))
        }
    }
}
