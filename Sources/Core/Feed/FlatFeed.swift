//
//  FlatFeed.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// `FlatFeed` are the only feeds that can be followed, and therefore are a good type to setup for adding activities.
/// `FlatFeed` can also be used to consume activities from other feeds - in a "timeline"-like manner.
public final class FlatFeed: Feed {
    
    /// Receive a feed activities type of `Activity`.
    ///
    /// - Parameters:
    ///     - enrich: when using collections, you can request to enrich activities to include them.
    ///     - pagination: a pagination options.
    ///     - ranking: the custom ranking formula used to sort the feed, must be defined in the dashboard.
    ///     - reactionsOptions: options to include reactions to activities. Check options in docs for `FeedReactionsOptions`
    ///     - completion: a completion handler with an array of the `Activity` type.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func get(enrich: Bool = true,
                    pagination: Pagination = .none,
                    ranking: String? = nil,
                    includeReactions reactionsOptions: FeedReactionsOptions = [],
                    completion: @escaping ActivitiesCompletion<Activity>) -> Cancellable {
        return get(typeOf: Activity.self,
                   enrich: enrich,
                   pagination: pagination,
                   ranking: ranking,
                   includeReactions: reactionsOptions,
                   completion: completion)
    }
    
    /// Receive a feed activities with a custom activity type.
    ///
    /// - Parameters:
    ///     - typeOf: a type of custom activities that conformed to `ActivityProtocol`.
    ///     - enrich: when using collections, you can request to enrich activities to include them.
    ///     - pagination: a pagination options.
    ///     - ranking: the custom ranking formula used to sort the feed, must be defined in the dashboard.
    ///     - reactionsOptions: options to include reactions to activities. Check options in docs for `FeedReactionsOptions`
    ///     - completion: a completion handler with an array of a custom activity type.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func get<T: ActivityProtocol>(typeOf: T.Type,
                                         enrich: Bool = true,
                                         pagination: Pagination = .none,
                                         ranking: String? = nil,
                                         includeReactions reactionsOptions: FeedReactionsOptions = [],
                                         completion: @escaping ActivitiesCompletion<T>) -> Cancellable {
        let endpoint = FeedEndpoint.get(feedId, enrich, pagination, ranking ?? "", .none, reactionsOptions)
        return Client.shared.request(endpoint: endpoint) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
}

// MARK: - Client Flat Feed

extension Client {
    /// Get a flat feed with a given feed group `feedSlug` and `userId`.
    public func flatFeed(feedSlug: String, userId: String) -> FlatFeed {
        return flatFeed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    /// Get a flat feed with a given feed group `feedSlug` for the current user if it specified in the Token.
    ///
    /// - Note: If the current user is nil in the Token, then the returned feed would be nil.
    ///
    /// - Parameters:
    ///     - feedSlug: a feed group name.
    public func flatFeed(feedSlug: String) -> FlatFeed? {
        guard let userId = currentUserId else {
            return nil
        }
        
        return flatFeed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    /// Get a flat feed with a given `feedId`.
    public func flatFeed(_ feedId: FeedId) -> FlatFeed {
        return FlatFeed(feedId)
    }
}
