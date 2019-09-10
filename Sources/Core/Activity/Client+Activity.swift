//
//  Client+Activity.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 16/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// An activity completion block.
public typealias ActivityCompletion<T: Decodable> = (_ result: Result<T, ClientError>) -> Void
/// An activities completion block.
public typealias ActivitiesCompletion<T: Decodable> = (_ result: Result<Response<T>, ClientError>) -> Void

// MARK: - Client Activities

extension Client {
    
    /// Receive activities by activity ids with a custom activity type.
    ///
    /// - Note: A maximum length of list of activityIds is 100.
    @discardableResult
    public func get<T: ActivityProtocol>(enrich: Bool = true,
                                         typeOf type: T.Type,
                                         activityIds: [String],
                                         completion: @escaping ActivitiesCompletion<T>) -> Cancellable {
        return request(endpoint: ActivityEndpoint<T>.getByIds(enrich, activityIds)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Receive activities by pairs of `foreignId` and `time` with a custom activity type.
    ///
    /// - Note: A maximum length of list of foreignIds and times is 100.
    @discardableResult
    public func get<T: ActivityProtocol>(enrich: Bool = true,
                                         typeOf type: T.Type,
                                         foreignIds: [String],
                                         times: [Date],
                                         completion: @escaping ActivitiesCompletion<T>) -> Cancellable {
        return request(endpoint: ActivityEndpoint<T>.get(enrich, foreignIds: foreignIds, times: times)) { [weak self] result in
            if let self = self {
                result.parse(self.callbackQueue, completion)
            }
        }
    }
    
    /// Update activities data.
    ///
    /// - Note: When you update an activity, you must include the following fields both when adding and updating the activity:
    ///     - time
    ///     - foreignId
    /// - Note: It is not possible to update more than 100 activities per request with this method.
    /// - Note: When updating an activity any changes to the `feedIds` property are ignored.
    @discardableResult
    public func update<T: ActivityProtocol>(activities: [T], completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ActivityEndpoint<T>.update(activities)) { [weak self] result in
            if let self = self {
                result.parseStatusCode(self.callbackQueue, completion)
            }
        }
    }
    
    /// Update an activity fields by `activityId`.
    /// It is possible to update only a part of an activity with the partial update request.
    /// You can think of it as a quick "patching operation".
    ///
    /// - Note: Note: it is not possible to include the following reserved fields in a partial update request (set or unset):
    ///     - id
    ///     - actor
    ///     - verb
    ///     - object
    ///     - time
    ///     - target
    ///     - foreign_id
    ///     - to
    ///     - origin
    /// - Note: Note: the size of an activity's payload must be less than 10KB after all set and unset operations are applied.
    ///         The size is based on the size of the JSON-encoded activity.
    @discardableResult
    public func updateActivity<T: ActivityProtocol>(typeOf type: T.Type,
                                                    setProperties properties: Properties? = nil,
                                                    unsetPropertiesNames names: [String]? = nil,
                                                    activityId: String,
                                                    completion: @escaping ActivityCompletion<T>) -> Cancellable {
        return request(endpoint: ActivityEndpoint<T>.updateActivityById(setProperties: properties,
                                                                        unsetPropertiesNames: names,
                                                                        activityId: activityId)) { [weak self] result in
                                                                            if let self = self {
                                                                                result.parse(self.callbackQueue, completion)
                                                                            }
        }
    }
    
    
    /// Update an activity fields by `foreignId` and `time`.
    /// It is possible to update only a part of an activity with the partial update request.
    /// You can think of it as a quick "patching operation".
    ///
    /// - Note: Note: it is not possible to include the following reserved fields in a partial update request (set or unset):
    ///     - id
    ///     - actor
    ///     - verb
    ///     - object
    ///     - time
    ///     - target
    ///     - foreign_id
    ///     - to
    ///     - origin
    /// - Note: Note: the size of an activity's payload must be less than 10KB after all set and unset operations are applied.
    ///         The size is based on the size of the JSON-encoded activity.
    @discardableResult
    public func updateActivity<T: ActivityProtocol>(typeOf type: T.Type,
                                                    setProperties properties: Properties? = nil,
                                                    unsetPropertiesNames names: [String]? = nil,
                                                    foreignId: String,
                                                    time: Date,
                                                    completion: @escaping ActivityCompletion<T>) -> Cancellable {
        return request(endpoint: ActivityEndpoint<T>.updateActivity(setProperties: properties,
                                                                    unsetPropertiesNames: names,
                                                                    foreignId: foreignId,
                                                                    time: time)) { [weak self] result in
                                                                        if let self = self {
                                                                            result.parse(self.callbackQueue, completion)
                                                                        }
        }
    }
}
