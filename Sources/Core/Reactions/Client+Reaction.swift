//
//  Client+Reaction.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

// MARK: - Client Reactions

extension Client {
    
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
    public func add(reactionTo activityId: String,
                    parentReactionId: String? = nil,
                    kindOf kind: ReactionKind,
                    targetsFeedIds: FeedIds = [],
                    completion: @escaping DefaultReactionCompletion) -> Cancellable {
        return add(reactionTo: activityId,
                   parentReactionId: parentReactionId,
                   kindOf: kind,
                   extraData: EmptyReactionExtraData.shared,
                   userTypeOf: User.self,
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
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ReactionExtraDataProtocol, U: UserProtocol>(reactionTo activityId: String,
                                                                   parentReactionId: String? = nil,
                                                                   kindOf kind: ReactionKind,
                                                                   extraData: T,
                                                                   userTypeOf: U.Type,
                                                                   targetsFeedIds: FeedIds = [],
                                                                   completion: @escaping ReactionCompletion<T, U>) -> Cancellable {
        let endpoint = ReactionEndpoint.add(activityId, parentReactionId, kind, extraData, targetsFeedIds)
        
        return request(endpoint: endpoint) {  [weak self] result in
            if let self = self  {
                result.parseReaction(self.callbackQueue, completion)
            }
        }
    }
    
    /// Add a child reaction without any extra data.
    ///
    /// - Parameters:
    ///     - parentReaction: the parent reaction. It must be a reaction that has no parents.
    ///     - kind: the type of the reaction. Must not be empty or longer than 255 characters.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<P: ReactionExtraDataProtocol,
                    U: UserProtocol>(reactionToParentReaction parentReaction: Reaction<P, U>,
                                     kindOf kind: ReactionKind,
                                     userTypeOf userType: U.Type,
                                     targetsFeedIds: FeedIds = [],
                                     completion: @escaping ReactionCompletion<EmptyReactionExtraData, U>) -> Cancellable {
        return add(reactionToParentReaction: parentReaction,
                   kindOf: kind,
                   extraData: EmptyReactionExtraData.shared,
                   userTypeOf: userType,
                   targetsFeedIds: targetsFeedIds,
                   completion: completion)
    }
    
    /// Add a child reaction with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - parentReaction: the parent reaction. It must be a reaction that has no parents.
    ///     - kind: the type of the reaction. Must not be empty or longer than 255 characters.
    ///     - extraData: an extra data for the reaction. Should be an object type of `ReactionExtraDataProtocol`.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an added reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ReactionExtraDataProtocol,
                    P: ReactionExtraDataProtocol,
                    U: UserProtocol>(reactionToParentReaction parentReaction: Reaction<P, U>,
                                     kindOf kind: ReactionKind,
                                     extraData: T,
                                     userTypeOf userType: U.Type,
                                     targetsFeedIds: FeedIds = [],
                                     completion: @escaping ReactionCompletion<T, U>) -> Cancellable {
            return add(reactionTo: parentReaction.activityId,
                       parentReactionId: parentReaction.id,
                       kindOf: kind,
                       extraData: extraData,
                       userTypeOf: userType,
                       targetsFeedIds: targetsFeedIds,
                       completion: completion)
    }
    
    /// Add a reaction by id without any extra data.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - completion: a completion block with a reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get(reactionId: String, completion: @escaping DefaultReactionCompletion) -> Cancellable {
        return get(reactionId: reactionId, extraDataTypeOf: EmptyReactionExtraData.self, userTypeOf: User.self, completion: completion)
    }
    
    /// Add a reaction by id with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - extraDataTypeOf: a custom reaction extra data type `ReactionExtraDataProtocol` of an extra data.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - completion: a completion block with a reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get<T: ReactionExtraDataProtocol, U: UserProtocol>(reactionId: String,
                                                                   extraDataTypeOf: T.Type,
                                                                   userTypeOf: U.Type,
                                                                   completion: @escaping ReactionCompletion<T, U>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.get(reactionId)) { [weak self] result in
            if let self = self {
                result.parseReaction(self.callbackQueue, completion)
            }
        }
    }
    
    /// Update a reaction by id with extra data type of `ReactionExtraDataProtocol`.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - extraData: the updated extra data for the reaction.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - targetsFeedIds: target feeds for the reaction.
    ///     - completion: a completion block with an updated reaction.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func update<T: ReactionExtraDataProtocol,
                       U: UserProtocol>(reactionId: String,
                                        extraData: T,
                                        userTypeOf: U.Type,
                                        targetsFeedIds: FeedIds = [],
                                        completion: @escaping ReactionCompletion<T, U>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.update(reactionId, extraData, targetsFeedIds)) { [weak self] result in
            if let self = self {
                result.parseReaction(self.callbackQueue, completion)
            }
        }
    }
    
    /// Delete a reaction by id.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - completion: a completion block with a status code of the request.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func delete(reactionId: String, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ReactionEndpoint.delete(reactionId)) { [weak self] result in
            if let self = self {
                result.parseStatusCode(self.callbackQueue, completion)
            }
        }
    }
    
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
    public func reactions(forActivityId activityId: String,
                          kindOf kind: ReactionKind? = nil,
                          pagination: Pagination = .none,
                          withActivityData: Bool = false,
                          completion: @escaping DefaultReactionsCompletion) -> Cancellable {
        return reactions(forActivityId: activityId,
                         kindOf: kind,
                         extraDataTypeOf: EmptyReactionExtraData.self,
                         userTypeOf: User.self,
                         pagination: pagination,
                         withActivityData: withActivityData,
                         completion: completion)
    }
    
    /// Fetch reactions for the activityId.
    ///
    /// - Parameters:
    ///     - activityId: the activity id.
    ///     - kind: the type of reactions.
    ///     - extraDataTypeOf: a custom reaction extra data type `ReactionExtraDataProtocol` of an extra data.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - pagination: a pagination options.
    ///     - withActivityData: returns the activity data in the result for the given activity id.
    ///     - completion: a completion block with reactions and activity (optional).
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func reactions<T: ReactionExtraDataProtocol,
                          U: UserProtocol>(forActivityId activityId: String,
                                           kindOf kind: ReactionKind? = nil,
                                           extraDataTypeOf: T.Type,
                                           userTypeOf: U.Type,
                                           pagination: Pagination = .none,
                                           withActivityData: Bool = false,
                                           completion: @escaping ReactionsCompletion<T, U>) -> Cancellable {
        let endpoint = ReactionEndpoint.reactionsByActivityId(activityId, kind, pagination, withActivityData)
        return request(endpoint: endpoint) { [weak self] result in
            if let self = self {
                result.parseReactions(self.callbackQueue, completion)
            }
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
    public func reactions(forReactionId reactionId: String,
                          kindOf kind: ReactionKind? = nil,
                          pagination: Pagination = .none,
                          completion: @escaping DefaultReactionsCompletion) -> Cancellable {
        return reactions(forReactionId: reactionId,
                         kindOf: kind,
                         extraDataTypeOf: EmptyReactionExtraData.self,
                         userTypeOf: User.self,
                         pagination: pagination,
                         completion: completion)
    }
    
    /// Fetch reactions for the reactionId.
    ///
    /// - Parameters:
    ///     - reactionId: the reaction id.
    ///     - kind: the type of reactions.
    ///     - extraDataTypeOf: a custom reaction extra data type `ReactionExtraDataProtocol` of an extra data.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - pagination: a pagination options.
    ///     - completion: a completion block with reactions.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func reactions<T: ReactionExtraDataProtocol,
                          U: UserProtocol>(forReactionId reactionId: String,
                                           kindOf kind: ReactionKind? = nil,
                                           extraDataTypeOf: T.Type,
                                           userTypeOf: U.Type,
                                           pagination: Pagination = .none,
                                           completion: @escaping ReactionsCompletion<T, U>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByReactionId(reactionId, kind, pagination)) { [weak self] result in
            if let self = self {
                result.parseReactions(self.callbackQueue, completion)
            }
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
                          completion: @escaping DefaultReactionsCompletion) -> Cancellable {
        return reactions(forUserId: userId,
                         kindOf: kind,
                         extraDataTypeOf: EmptyReactionExtraData.self,
                         userTypeOf: User.self,
                         pagination: pagination,
                         completion: completion)
    }
    
    /// Fetch reactions for the userId.
    ///
    /// - Parameters:
    ///     - userId: the user id.
    ///     - kind: the type of reactions.
    ///     - extraDataTypeOf: a custom reaction extra data type `ReactionExtraDataProtocol` of an extra data.
    ///     - userTypeOf: a custom user type of the reaction.
    ///     - pagination: a pagination options.
    ///     - completion: a completion block with reactions.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func reactions<T: ReactionExtraDataProtocol,
                          U: UserProtocol>(forUserId userId: String,
                                           kindOf kind: ReactionKind? = nil,
                                           extraDataTypeOf: T.Type,
                                           userTypeOf: U.Type,
                                           pagination: Pagination = .none,
                                           completion: @escaping ReactionsCompletion<T, U>) -> Cancellable {
        return request(endpoint: ReactionEndpoint.reactionsByUserId(userId, kind, pagination)) { [weak self] result in
            if let self = self {
                result.parseReactions(self.callbackQueue, completion)
            }
        }
    }
}
