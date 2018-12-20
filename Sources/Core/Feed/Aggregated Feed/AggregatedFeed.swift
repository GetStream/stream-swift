//
//  AggregatedFeed.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

public typealias GroupCompletion<T: ActivityProtocol> = (_ result: Result<[Group<T>], ClientError>) -> Void

public final class AggregatedFeed: Feed {
    
    /// Receive an aggregated feed activities type of `Activity`.
    ///
    /// - Parameters:
    ///     - enrich: when using collections, you can request to enrich activities to include them.
    ///     - pagination: a pagination options.
    ///     - ranking: the custom ranking formula used to sort the feed, must be defined in the dashboard.
    ///     - markOption: mark options to update feed notifications as read/seen.
    ///     - reactionsOptions: options to include reactions to activities. Check optionsin docs for `FeedReactionsOptions`
    ///     - completion: a completion handler with Result of `Activity`.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func get(enrich: Bool = true,
                    pagination: Pagination = .none,
                    ranking: String? = nil,
                    markOption: FeedMarkOption = .none,
                    reactionsOptions: FeedReactionsOptions = [],
                    completion: @escaping GroupCompletion<Activity>) -> Cancellable {
        return get(typeOf: Activity.self,
                   enrich: enrich,
                   pagination: pagination,
                   ranking: ranking,
                   markOption: markOption,
                   reactionsOptions: reactionsOptions,
                   completion: completion)
    }
    
    /// Receive an aggregated feed activities with a custom activity type.
    ///
    /// - Parameters:
    ///     - typeOf: a type of activities that conformed to `ActivityProtocol`.
    ///     - enrich: when using collections, you can request to enrich activities to include them.
    ///     - pagination: a pagination options.
    ///     - ranking: the custom ranking formula used to sort the feed, must be defined in the dashboard.
    ///     - markOption: mark options to update feed notifications as read/seen.
    ///     - reactionsOptions: options to include reactions to activities. Check optionsin docs for `FeedReactionsOptions`
    ///     - completion: a completion handler with Result of a custom activity type.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func get<T: ActivityProtocol>(typeOf: T.Type,
                                         enrich: Bool = true,
                                         pagination: Pagination = .none,
                                         ranking: String? = nil,
                                         markOption: FeedMarkOption = .none,
                                         reactionsOptions: FeedReactionsOptions = [],
                                         completion: @escaping GroupCompletion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.get(feedId, enrich, pagination, ranking ?? "", markOption, reactionsOptions)) {
            $0.parseGroup(completion)
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
        return AggregatedFeed(feedId, client: self)
    }
}
