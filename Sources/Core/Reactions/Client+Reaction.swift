//
//  Client+Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

public typealias ReactionCompletion<T: ReactionExtraDataProtocol> = (_ result: Result<Reaction<T>, ClientError>) -> Void
public typealias ReactionsCompletion<T: ReactionExtraDataProtocol> = (_ result: Result<Reactions<T>, ClientError>) -> Void

// MARK: - Client Reactions

extension Client {
    
    // MARK: - Add
    
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
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Get
    
    @discardableResult
    public func reaction(id: UUID, completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return reaction(id: id, extraDataTypeOf: ReactionNoExtraData.self, completion: completion)
    }
    
    @discardableResult
    public func reaction<T: ReactionExtraDataProtocol>(id: UUID,
                                                       extraDataTypeOf: T.Type,
                                                       completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.get(id)) {
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Update
    
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
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Delete
    
    @discardableResult
    public func delete(reactionId: UUID, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ReactionEndpoint.delete(reactionId)) {
            $0.parseStatusCode(completion)
        }
    }
    
    // MARK: - Fetch Reactions
    
    @discardableResult
    public func reactions(forActivityId activityId: UUID,
                          kindOf kind: ReactionKind? = nil,
                          pagination: Pagination = .none,
                          withActivityData: Bool = false,
                          completion: @escaping ReactionsCompletion<ReactionNoExtraData>) -> Cancellable {
        return reactions(forActivityId: activityId,
                         kindOf: kind,
                         extraDataTypeOf: ReactionNoExtraData.self,
                         pagination: pagination,
                         withActivityData: withActivityData,
                         completion: completion)
    }
    
    @discardableResult
    public func reactions<T: ReactionExtraDataProtocol>(forActivityId activityId: UUID,
                                                        kindOf kind: ReactionKind? = nil,
                                                        extraDataTypeOf: T.Type,
                                                        pagination: Pagination = .none,
                                                        withActivityData: Bool = false,
                                                        completion: @escaping ReactionsCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByActivityId(activityId, kind, pagination, withActivityData)) {
            $0.parseReactions(completion)
        }
    }
    
    @discardableResult
    public func reactions(forReactionId reactionId: UUID,
                          kindOf kind: ReactionKind? = nil,
                          pagination: Pagination = .none,
                          completion: @escaping ReactionsCompletion<ReactionNoExtraData>) -> Cancellable {
        return reactions(forReactionId: reactionId,
                         kindOf: kind,
                         extraDataTypeOf: ReactionNoExtraData.self,
                         pagination: pagination,
                         completion: completion)
    }
    
    @discardableResult
    public func reactions<T: ReactionExtraDataProtocol>(forReactionId reactionId: UUID,
                                                        kindOf kind: ReactionKind? = nil,
                                                        extraDataTypeOf: T.Type,
                                                        pagination: Pagination = .none,
                                                        completion: @escaping ReactionsCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByReactionId(reactionId, kind, pagination)) {
            $0.parseReactions(completion)
        }
    }
    
    @discardableResult
    public func reactions(forUserId userId: String,
                          kindOf kind: ReactionKind? = nil,
                          pagination: Pagination = .none,
                          completion: @escaping ReactionsCompletion<ReactionNoExtraData>) -> Cancellable {
        return reactions(forUserId: userId,
                         kindOf: kind,
                         extraDataTypeOf: ReactionNoExtraData.self,
                         pagination: pagination,
                         completion: completion)
    }
    
    @discardableResult
    public func reactions<T: ReactionExtraDataProtocol>(forUserId userId: String,
                                                        kindOf kind: ReactionKind? = nil,
                                                        extraDataTypeOf: T.Type,
                                                        pagination: Pagination = .none,
                                                        completion: @escaping ReactionsCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByUserId(userId, kind, pagination)) {
            $0.parseReactions(completion)
        }
    }
}
