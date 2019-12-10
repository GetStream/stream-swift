//
//  Feed.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 09/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

typealias ActivityResponse = EnrichedActivity<String, String, DefaultReaction>

/// A followers completion block.
public typealias FollowersCompletion = (_ result: Result<Response<Follower>, ClientError>) -> Void

/// A superclass for feeds: `FlatFeed`, `AggregatedFeed` and `NotificationFeed`.
public class Feed: CustomStringConvertible {
    /// A feed id.
    public let feedId: FeedId
    /// A separated callback queue from `client.callbackQueue` for completion requests.
    public var callbackQueue: DispatchQueue
    
    /// Returns a feedId description of the feed.
    public var description: String {
        return feedId.description
    }
    
    /// Create a general feed.
    ///
    /// - Parameters:
    ///     - feedId: a `FeedId`
    ///     - client: a Stream client.
    ///     - callbackQueue: a callback queue for completion requests. If nil, then `client.callbackQueue` would be used.
    public init(_ feedId: FeedId, callbackQueue: DispatchQueue? = nil) {
        self.feedId = feedId
        self.callbackQueue = callbackQueue ?? Client.shared.callbackQueue
    }
}

// MARK: - Feed Activity

extension Feed {
    /// Add a new activity.
    ///
    /// - Parameters:
    ///     - activity: an activity to add.
    ///     - completion: a completion block with the activity that was added.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func add<T: ActivityProtocol>(_ activity: T, completion: @escaping ActivityCompletion<T>) -> Cancellable {
        return Client.shared.request(endpoint: FeedActivityEndpoint.add(activity, feedId: feedId)) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .failure(let clientError) = result {
                self.callbackQueue.async { completion(.failure(clientError)) }
                return
            }
            
            /// The response is always for a not enriched activity.
            /// Check if the given activity is not enriched.
            if T.ActorType.self == String.self, T.ObjectType.self == String.self {
                result.parse(self.callbackQueue, completion)
                return
            }
            
            /// Parse the response with the default `Activity` and populate the given activity with `id` and `time` properties.
            let activityCompletion: ActivityCompletion<ActivityResponse> = { (result: Result<ActivityResponse, ClientError>) in
                do {
                    let addedActivity = try result.get()
                    var activity = activity
                    activity.id = addedActivity.id
                    
                    if activity.time == nil {
                        activity.time = addedActivity.time
                    }
                    
                    self.callbackQueue.async { completion(.success(activity)) }
                } catch {
                    self.callbackQueue.async { completion(.failure(.unexpectedError(error))) }
                }
            }
            
            result.parse(self.callbackQueue, activityCompletion)
        }
    }
    
    /// Remove an activity by the activityId.
    ///
    /// - Parameters:
    ///     - activityId: an activityId to remove.
    ///     - completion: a completion block with removed activityId.
    /// - Returns: an object to cancel the request.
    @discardableResult
    public func remove(activityId: String, completion: @escaping RemovedCompletion) -> Cancellable {
        return Client.shared.request(endpoint: FeedEndpoint.deleteById(activityId, feedId: feedId)) { [weak self] result in
            if let self = self {
                result.parseRemoved(self.callbackQueue, completion)
            }
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
        return Client.shared.request(endpoint: FeedEndpoint.deleteByForeignId(foreignId, feedId: feedId)) { [weak self] result in
            if let self = self {
                result.parseRemoved(self.callbackQueue, completion)
            }
        }
    }
}
