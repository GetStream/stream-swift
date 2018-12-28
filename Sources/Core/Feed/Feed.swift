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

public typealias FollowersCompletion = (_ result: Result<[Follower], ClientError>) -> Void

public class Feed: CustomStringConvertible {
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

// MARK: - Add a new Activity

extension Feed {
    /// Add a new activity.
    ///
    /// - Parameters:
    ///     - activity: an activity to add.
    ///     - completion: a completion block with activities that was added.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ActivityProtocol>(_ activity: T, completion: @escaping ActivitiesCompletion<T>) -> Cancellable {
        return client.request(endpoint: FeedActivityEndpoint.add(activity, feedId: feedId)) {
            if case .failure(let clientError) = $0 {
                completion(.failure(clientError))
                return
            }
            
            /// The response is always for a not enriched activity.
            /// Check if the given activity is not enriched.
            if T.ActorType.self == String.self, T.ObjectType.self == String.self, T.TargetType.self == String.self {
                $0.parseActivities(completion)
                return
            }
            
            /// Parse the response with the default `Activity` and populate the given activity with `id` and `time` properties.
            let activityCompletion: ActivitiesCompletion<Activity> = {
                do {
                    if let addedActivity = try $0.dematerialize().first {
                        var activity = activity
                        activity.id = addedActivity.id
                        
                        if activity.time == nil {
                            activity.time = addedActivity.time
                        }
                        
                        completion(.success([activity]))
                    } else {
                        completion(.failure(.unexpectedError))
                    }
                } catch {
                    completion(.failure(.unexpectedError))
                }
            }
            
            $0.parseActivities(activityCompletion)
        }
    }
}

// MARK: - Delete a new Activity

extension Feed {
    /// Remove an activity by the activityId.
    ///
    /// - Parameters:
    ///     - activityId: an activityId to remove.
    ///     - completion: a completion block with removed activityId.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func remove(activityId: UUID, completion: @escaping RemovedCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.deleteById(activityId, feedId: feedId)) {
            $0.parseRemoved(completion)
        }
    }
    
    /// Remove an activity by the foreignId.
    ///
    /// - Parameters:
    ///     - foreignId: an foreignId to remove.
    ///     - completion: a completion block with removed activityId.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func remove(foreignId: String, completion: @escaping RemovedCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.deleteByForeignId(foreignId, feedId: feedId)) {
            $0.parseRemoved(completion)
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
    /// - Returns: an object to cancel the request.
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
    /// - Returns: an object to cancel the request.
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
    /// - Returns: an object to cancel the request.
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
