//
//  Client+Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

extension Client {
    
    // MARK: - Add
    
    /// Add a reaction to the activity without any extra data.
    ///
    /// - Parameters:
    ///     - activityId: the activity id for the reaction. Must be a valid activity id.
    ///     - parentReactionId: the id of the parent reaction. If provided, it must be the id of a reaction that has no parents.
    ///     - kind: the type of the reaction. Must not be empty or longer than 255 characters.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with a created reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add(reactionTo activityId: UUID,
                    parentReactionId: UUID? = nil,
                    kindOf kind: ReactionKind,
                    targetsFeedIds: [FeedId] = [],
                    completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return add(reactionTo: activityId,
                   parentReactionId: parentReactionId,
                   kindOf: kind,
                   extraData: ReactionNoExtraData.shared,
                   targetsFeedIds: targetsFeedIds,
                   completion: completion)
    }
    
    /// Add a reaction to the activity with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - activityId: the activity id for the reaction. Must be a valid activity id.
    ///     - parentReactionId: the id of the parent reaction. If provided, it must be the id of a reaction that has no parents.
    ///     - kind: the type of the reaction. Must not be empty or longer than 255 characters.
    ///     - data: an extra data for the reaction. Should be an object type of `ReactionExtraDataProtocol`.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with a created reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ReactionExtraDataProtocol>(reactionTo activityId: UUID,
                                                  parentReactionId: UUID? = nil,
                                                  kindOf kind: ReactionKind,
                                                  extraData: T,
                                                  targetsFeedIds: [FeedId] = [],
                                                  completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.add(activityId, parentReactionId, kind, extraData, targetsFeedIds)) {
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Get
    
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get(reactionId: UUID, completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return get(reactionId: reactionId, extraDataTypeOf: ReactionNoExtraData.self, completion: completion)
    }
    
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get<T: ReactionExtraDataProtocol>(reactionId: UUID,
                                                  extraDataTypeOf: T.Type,
                                                  completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.get(reactionId)) {
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Update
    
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func update(reactionId: UUID,
                       targetsFeedIds: [FeedId] = [],
                       completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return update(reactionId: reactionId,
                      extraData: ReactionNoExtraData.shared,
                      targetsFeedIds: targetsFeedIds,
                      completion: completion)
    }
    
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func update<T: ReactionExtraDataProtocol>(reactionId: UUID,
                                                     extraData: T,
                                                     targetsFeedIds: [FeedId] = [],
                                                     completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.update(reactionId, extraData, targetsFeedIds)) {
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Delete
    
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func delete(reactionId: UUID, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ReactionEndpoint.delete(reactionId)) {
            $0.parseStatusCode(completion)
        }
    }
    
    // MARK: - Fetch Reactions
    
    /// - Returns: an object to cancel the request.
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
    
    /// - Returns: an object to cancel the request.
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
    
    /// - Returns: an object to cancel the request.
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
    
    /// - Returns: an object to cancel the request.
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
    
    /// - Returns: an object to cancel the request.
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
    
    /// - Returns: an object to cancel the request.
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
