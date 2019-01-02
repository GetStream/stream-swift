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
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add(reactionTo activityId: UUID,
                    parentReactionId: UUID? = nil,
                    kindOf kind: ReactionKind,
                    targetsFeedIds: FeedIds = [],
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
    ///     - extraData: an extra data for the reaction. Should be an object type of `ReactionExtraDataProtocol`.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ReactionExtraDataProtocol>(reactionTo activityId: UUID,
                                                  parentReactionId: UUID? = nil,
                                                  kindOf kind: ReactionKind,
                                                  extraData: T,
                                                  targetsFeedIds: FeedIds = [],
                                                  completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.add(activityId, parentReactionId, kind, extraData, targetsFeedIds)) {
            $0.parseReaction(completion)
        }
    }
    
    /// Add a child reaction without any extra data.
    ///
    /// - Parameters:
    ///     - parentReaction: the parent reaction. It must be a reaction that has no parents.
    ///     - kind: the type of the reaction. Must not be empty or longer than 255 characters.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<U: ReactionExtraDataProtocol>(reactionToParentReaction parentReaction: Reaction<U>,
                                                  kindOf kind: ReactionKind,
                                                  targetsFeedIds: FeedIds = [],
                                                  completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return add(reactionToParentReaction: parentReaction,
                   kindOf: kind,
                   extraData: ReactionNoExtraData.shared,
                   targetsFeedIds: targetsFeedIds,
                   completion: completion)
    }
    
    /// Add a child reaction with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - parentReaction: the parent reaction. It must be a reaction that has no parents.
    ///     - kind: the type of the reaction. Must not be empty or longer than 255 characters.
    ///     - extraData: an extra data for the reaction. Should be an object type of `ReactionExtraDataProtocol`.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ReactionExtraDataProtocol, U: ReactionExtraDataProtocol>(reactionToParentReaction parentReaction: Reaction<U>,
                                                                                kindOf kind: ReactionKind,
                                                                                extraData: T,
                                                                                targetsFeedIds: FeedIds = [],
                                                                                completion: @escaping ReactionCompletion<T>)
        -> Cancellable {
            return add(reactionTo: parentReaction.activityId,
                       parentReactionId: parentReaction.id,
                       kindOf: kind,
                       extraData: extraData,
                       targetsFeedIds: targetsFeedIds,
                       completion: completion)
    }
    
    // MARK: - Get
    
    /// Add a reaction by id without any extra data.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - completion: a completion block with a reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get(reactionId: UUID, completion: @escaping ReactionCompletion<ReactionNoExtraData>) -> Cancellable {
        return get(reactionId: reactionId, extraDataTypeOf: ReactionNoExtraData.self, completion: completion)
    }
    
    /// Add a reaction by id with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - extraDataTypeOf: the `ReactionExtraDataProtocol` type of an extra data.
    ///     - completion: a completion block with a reaction.
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
    
    /// Update a reaction by id with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - extraData: the updated extra data for the reaction.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an updated reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func update<T: ReactionExtraDataProtocol>(reactionId: UUID,
                                                     extraData: T,
                                                     targetsFeedIds: FeedIds = [],
                                                     completion: @escaping ReactionCompletion<T>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.update(reactionId, extraData, targetsFeedIds)) {
            $0.parseReaction(completion)
        }
    }
    
    // MARK: - Delete
    
    /// Delete a reaction by id.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - completion: a completion block with a status code of the request.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func delete(reactionId: UUID, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ReactionEndpoint.delete(reactionId)) {
            $0.parseStatusCode(completion)
        }
    }
    
    // MARK: - Fetch Reactions
    
    /// Fetch reactions without any extra data for the activityId.
    ///
    /// - Parameters:
    ///     - activityId: the activity id.
    ///     - kind: the type of reactions.
    ///     - pagination: a pagination options.
    ///     - withActivityData: returns the activity data in the result for the given activity id.
    ///     - completion: a completion block with reactions and activity (optional).
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
    
    /// Fetch reactions for the activityId.
    ///
    /// - Parameters:
    ///     - activityId: the activity id.
    ///     - kind: the type of reactions.
    ///     - extraDataTypeOf: the `ReactionExtraDataProtocol` type of an extra data.
    ///     - pagination: a pagination options.
    ///     - withActivityData: returns the activity data in the result for the given activity id.
    ///     - completion: a completion block with reactions and activity (optional).
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
    
    /// Fetch reactions without any extra data for the reactionId.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - kind: the type of reactions.
    ///     - pagination: a pagination options.
    ///     - completion: a completion block with reactions.
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
    
    /// Fetch reactions for the reactionId.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - kind: the type of reactions.
    ///     - extraDataTypeOf: the `ReactionExtraDataProtocol` type of an extra data.
    ///     - pagination: a pagination options.
    ///     - completion: a completion block with reactions.
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
    
    /// Fetch reactions without any extra data for the userId.
    ///
    /// - Parameters:
    ///     - userId: the user id.
    ///     - kind: the type of reactions.
    ///     - pagination: a pagination options.
    ///     - completion: a completion block with reactions.
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
    
    /// Fetch reactions for the userId.
    ///
    /// - Parameters:
    ///     - userId: the user id.
    ///     - kind: the type of reactions.
    ///     - extraDataTypeOf: the `ReactionExtraDataProtocol` type of an extra data.
    ///     - pagination: a pagination options.
    ///     - completion: a completion block with reactions.
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
