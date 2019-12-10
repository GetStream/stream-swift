//
//  AggregatedFeed.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// `AggregatedFeed` are good for consuming activities in an "aggregated"-like manner. You cannot follow an aggregated feed,
/// but you may on occasion want to add activities to one.
public final class AggregatedFeed: Feed {
    
    /// Receive an aggregated feed activities type of `Activity`.
    ///
    /// - Parameters:
    ///     - enrich: when using collections, you can request to enrich activities to include them.
    ///     - pagination: a pagination options.
    ///     - reactionsOptions: options to include reactions to activities. Check optionsin docs for `FeedReactionsOptions`
    ///     - completion: a completion handler with a group of the `Activity` type.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get(enrich: Bool = true,
                    pagination: Pagination = .none,
                    includeReactions reactionsOptions: FeedReactionsOptions = [],
                    completion: @escaping GroupCompletion<Activity, Group<Activity>>) -> Cancellable {
        return get(typeOf: Activity.self,
                   enrich: enrich,
                   pagination: pagination,
                   includeReactions: reactionsOptions,
                   completion: completion)
    }
    
    /// Receive an aggregated feed activities with a custom activity type.
    ///
    /// - Parameters:
    ///     - typeOf: a type of custom activities that conformed to `ActivityProtocol`.
    ///     - enrich: when using collections, you can request to enrich activities to include them.
    ///     - pagination: a pagination options.
    ///     - reactionsOptions: options to include reactions to activities. Check optionsin docs for `FeedReactionsOptions`
    ///     - completion: a completion handler with a group with a custom activity type.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func get<T: ActivityProtocol>(typeOf: T.Type,
                                         enrich: Bool = true,
                                         pagination: Pagination = .none,
                                         includeReactions reactionsOptions: FeedReactionsOptions = [],
                                         completion: @escaping GroupCompletion<T, Group<T>>) -> Cancellable {
        let endpoint = FeedEndpoint.get(feedId, enrich, pagination, "", .none, reactionsOptions)
        return Client.shared.request(endpoint: endpoint) { [weak self] result in
            if let self = self {
                result.parseGroup(self.callbackQueue, completion)
            }
        }
    }
}

// MARK: - Client Aggregated Feed

extension Client {
    /// Get an aggregated feed with a given feed group `feedSlug` and `userId`.
    public func aggregatedFeed(feedSlug: String, userId: String) -> AggregatedFeed {
        return aggregatedFeed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    /// Get an aggregated feed with a given feed group `feedSlug` for the current user if it specified in the Token.
    ///
    /// - Note: If the current user is nil in the Token, then the returned feed would be nil.
    ///
    /// - Parameters:
    ///     - feedSlug: a feed group name.
    public func aggregatedFeed(feedSlug: String) -> AggregatedFeed? {
        guard let userId = currentUserId else {
            return nil
        }
        
        return aggregatedFeed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    /// Get an aggregated feed with a given `feedId`.
    public func aggregatedFeed(_ feedId: FeedId) -> AggregatedFeed {
        return AggregatedFeed(feedId)
    }
}
