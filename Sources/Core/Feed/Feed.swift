//
//  Feed.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 09/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

public typealias RemovedCompletion = (_ result: Result<String, ClientError>) -> Void
public typealias FollowersCompletion = (_ result: Result<[Follower], ClientError>) -> Void

public struct Feed: CustomStringConvertible {
    public let feedId: FeedId
    let client: Client
    
    public var description: String {
        return feedId.description
    }
    
    public init(_ feedId: FeedId, client: Client) {
        self.feedId = feedId
        self.client = client
    }
}

extension Client {
    /// Get a `Feed` with a given feed group `feedSlug` and `userId`.
    public func feed(feedSlug: String, userId: String) -> Feed {
        return feed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    /// Get a `Feed` with a given feed group `feedSlug` for the current user if it specified in the Token.
    ///
    /// - Note: If the current user is nil in the Token, then the returned feed would be nil.
    ///
    /// - Parameters:
    ///     - feedSlug: a feed group name.
    public func feed(feedSlug: String) -> Feed? {
        guard let userId = currentUserId else {
            return nil
        }
        
        return feed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    /// Get a `Feed` with a given `feedId`.
    public func feed(_ feedId: FeedId) -> Feed {
        return Feed(feedId, client: self)
    }
}

// MARK: - Add a new Activity

extension Feed {
    /// Add a new activity.
    @discardableResult
    public func add<T: ActivityProtocol>(_ activity: T, completion: @escaping ActivitiesCompletion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.add(activity, feedId: feedId)) {
            $0.parseActivities(completion)
        }
    }
}

// MARK: - Delete a new Activity

extension Feed {
    /// Remove an activity by the activityId.
    @discardableResult
    public func remove(by activityId: UUID, completion: @escaping RemovedCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.deleteById(activityId, feedId: feedId)) {
            $0.parseRemoved(completion)
        }
    }
    
    /// Remove an activity by the foreignId.
    @discardableResult
    public func remove(by foreignId: String, completion: @escaping RemovedCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.deleteByForeignId(foreignId, feedId: feedId)) {
            $0.parseRemoved(completion)
        }
    }
}

// MARK: - Receive Feed Activities

extension Feed {
    /// Receive feed activities with a custom activity type.
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
                                         completion: @escaping ActivitiesCompletion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.get(feedId, enrich, pagination, ranking ?? "", markOption, reactionsOptions)) {
            $0.parseActivities(inContainer: true, completion)
        }
    }
}

// MARK: - Following

extension Feed {
    /// Follows a target feed.
    ///
    /// - Parameters:
    ///     - target: the target feed this feed should follow, e.g. user:44.
    ///     - activityCopyLimit: how many activities should be copied from the target feed, max 1000, default 100.
    @discardableResult
    public func follow(to target: FeedId, activityCopyLimit: Int = 100, completion: @escaping StatusCodeCompletion) -> Cancellable {
        let activityCopyLimit = max(0, min(1000, activityCopyLimit))
        let endpoint = FeedEndpoint.follow(feedId, target: target, activityCopyLimit: activityCopyLimit)
        
        return client.request(endpoint: endpoint) { $0.parseStatusCode(completion) }
    }
    
    @discardableResult
    public func unfollow(from target: FeedId, keepHistory: Bool = false, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.unfollow(feedId, target: target, keepHistory: keepHistory)) {
            $0.parseStatusCode(completion)
        }
    }
    
    /// Returns a paginated list of followers.
    ///
    /// - Parameters:
    ///     - offset: number of followers to skip before returning results, max 400.
    ///     - limit: amount of results per request, max 500, default 25.
    ///     - completion: a result with `Follower`'s or an error.
    /// - Note: the number of followers that can be retrieved is limited to 1000.
    @discardableResult
    public func followers(offset: Int = 0, limit: Int = 25, completion: @escaping FollowersCompletion) -> Cancellable {
        let limit = max(0, min(500, limit))
        let offset = max(0, min(400, offset))
        
        return client.request(endpoint: FeedEndpoint.followers(feedId, offset: offset, limit: limit)) {
            $0.parse(completion)
        }
    }
    
    /// Returns a paginated list of the feeds which are followed by the feed.
    ///
    /// - Parameters:
    ///     - filter: list of feeds to filter results on.
    ///     - offset: number of followers to skip before returning results, max 400.
    ///     - limit: amount of results per request, max 500, default 25.
    ///     - completion: a result with `Follower`'s or an error.
    /// - Note: the number of followers that can be retrieved is limited to 1000.
    @discardableResult
    public func following(filter: FeedIds = [],
                          offset: Int = 0,
                          limit: Int = 25,
                          completion: @escaping FollowersCompletion) -> Cancellable {
        let limit = max(0, min(500, limit))
        let offset = max(0, min(400, offset))
        
        return client.request(endpoint: FeedEndpoint.following(feedId, filter: filter, offset: offset, limit: limit)) {
            $0.parse(completion)
        }
    }
}
