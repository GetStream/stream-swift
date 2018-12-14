//
//  Client+Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

public typealias ReactionExtraDataProtocol = Codable
public typealias ReactionCompletion<T: ReactionExtraDataProtocol> = (_ result: Result<Reaction<T>, ClientError>) -> Void

// MARK: - Client Reactions

extension Client {
    
    // MARK: Add
    
    @discardableResult
    public func addReaction(to activityId: UUID,
                            parentReactionId: UUID? = nil,
                            kindOf kind: ReactionKind,
                            targetsFeedIds: [FeedId] = [],
                            completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return addReaction(to: activityId,
                           parentReactionId: parentReactionId,
                           kindOf: kind,
                           data: ReactionNoExtraData.shared,
                           targetsFeedIds: targetsFeedIds,
                           completion: completion)
    }
    
    @discardableResult
    public func addReaction<T: ReactionExtraDataProtocol>(to activityId: UUID,
                                                          parentReactionId: UUID? = nil,
                                                          kindOf kind: ReactionKind,
                                                          data: T,
                                                          targetsFeedIds: [FeedId] = [],
                                                          completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.add(activityId, parentReactionId, kind, data, targetsFeedIds)) {
            $0.parseReaction(completion: completion)
        }
    }
    
    // MARK: Get
    
    @discardableResult
    public func reaction(id: UUID, completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return reaction(id: id, extraDataTypeOf: ReactionNoExtraData.self, completion: completion)
    }
    
    @discardableResult
    public func reaction<T: ReactionExtraDataProtocol>(id: UUID,
                                                       extraDataTypeOf: T.Type,
                                                       completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.get(id)) {
            $0.parseReaction(completion: completion)
        }
    }
    
    // MARK: Update
    
    @discardableResult
    public func update(reactionId: UUID,
                       targetsFeedIds: [FeedId] = [],
                       completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return update(reactionId: reactionId,
                      data: ReactionNoExtraData.shared,
                      targetsFeedIds: targetsFeedIds,
                      completion: completion)
    }
    
    @discardableResult
    public func update<T: ReactionExtraDataProtocol>(reactionId: UUID,
                                                     data: T,
                                                     targetsFeedIds: [FeedId] = [],
                                                     completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.update(reactionId, data, targetsFeedIds)) {
            $0.parseReaction(completion: completion)
        }
    }
    
    // MARK: Delete
    
    @discardableResult
    public func delete(reactionId: UUID, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ReactionEndpoint.delete(reactionId)) {
            $0.parseStatusCode(completion: completion)
        }
    }
    
    // MARK: Fetch
    
    @discardableResult
    public func reactions(forActivityId activityId: UUID,
                          kind: ReactionKind? = nil,
                          pagination: Pagination = .none,
                          withActivityData: Bool = false) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByActivityId(activityId, kind, pagination, withActivityData)) {
            print($0)
        }
    }
    
    @discardableResult
    public func reactions(forReactionId reactionId: UUID, kind: ReactionKind? = nil, pagination: Pagination = .none) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByReactionId(reactionId, kind, pagination)) {
            print($0)
        }
    }
    
    @discardableResult
    public func reactions(forUserId userId: String, kind: ReactionKind? = nil, pagination: Pagination = .none) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByUserId(userId, kind, pagination)) {
            print($0)
        }
    }
}
