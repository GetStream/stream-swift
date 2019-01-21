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

public typealias FollowersCompletion = (_ result: Result<Response<Follower>, ClientError>) -> Void

/// A superclass for feeds: `FlatFeed`, `AggregatedFeed` and `NotificationFeed`.
public class Feed: CustomStringConvertible {
    public let feedId: FeedId
    public let client: Client
    
    /// Returns a feedId description of the feed.
    public var description: String {
        return feedId.description
    }
    
    /// Create a general feed.
    ///
    /// - Parameters:
    ///     - feedId: a `FeedId`
    ///     - client: a Stream client.
    public init(_ feedId: FeedId, client: Client) {
        self.feedId = feedId
        self.client = client
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
        return client.request(endpoint: FeedActivityEndpoint.add(activity, feedId: feedId)) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if case .failure(let clientError) = result {
                self.client.callbackQueue.async { completion(.failure(clientError)) }
                return
            }
            
            /// The response is always for a not enriched activity.
            /// Check if the given activity is not enriched.
            if T.ActorType.self == String.self, T.ObjectType.self == String.self, T.TargetType.self == String.self {
                result.parse(self.client.callbackQueue, completion)
                return
            }
            
            /// Parse the response with the default `Activity` and populate the given activity with `id` and `time` properties.
            let activityCompletion: ActivityCompletion<Activity> = {
                do {
                    let addedActivity = try $0.get()
                    var activity = activity
                    activity.id = addedActivity.id
                    
                    if activity.time == nil {
                        activity.time = addedActivity.time
                    }
                    
                    self.client.callbackQueue.async { completion(.success(activity)) }
                } catch {
                    self.client.callbackQueue.async { completion(.failure(.unexpectedError)) }
                }
            }
            
            result.parse(self.client.callbackQueue, activityCompletion)
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
        return client.request(endpoint: FeedEndpoint.deleteById(activityId, feedId: feedId)) { [weak self] result in
            if let self = self {
                result.parseRemoved(self.client.callbackQueue, completion)
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
        return client.request(endpoint: FeedEndpoint.deleteByForeignId(foreignId, feedId: feedId)) { [weak self] result in
            if let self = self {
                result.parseRemoved(self.client.callbackQueue, completion)
            }
        }
    }
}
