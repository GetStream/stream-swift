//
//  Client+Activity.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 16/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

extension Client {
    
    /// Receive activities by activity ids.
    ///
    /// - Note: A maximum length of list of activityIds is 100.
    @discardableResult
    public func get(activityIds: [UUID], completion: @escaping Completion<Activity>) -> Cancellable {
        return get(typeOf: Activity.self, activityIds: activityIds, completion: completion)
    }

    /// Receive activities by activity ids with a custom activity type.
    ///
    /// - Note: A maximum length of list of activityIds is 100.
    @discardableResult
    public func get<T: ActivityProtocol>(typeOf type: T.Type,
                                         activityIds: [UUID],
                                         completion: @escaping Completion<T>) -> Cancellable {
        return request(endpoint: ActivityEndpoint.getByIds(activityIds)) {
            Client.parseResultsResponse($0, inContainer: true, completion: completion)
        }
    }
    
    /// Receive activities by pairs of `foreignId` and `time`.
    ///
    /// - Note: A maximum length of list of foreignIds and times is 100.
    @discardableResult
    public func get(foreignIds: [String], times: [Date], completion: @escaping Completion<Activity>) -> Cancellable {
        return get(typeOf: Activity.self, foreignIds: foreignIds, times: times, completion: completion)
    }
    
    /// Receive activities by pairs of `foreignId` and `time` with a custom activity type.
    ///
    /// - Note: A maximum length of list of foreignIds and times is 100.
    @discardableResult
    public func get<T: ActivityProtocol>(typeOf type: T.Type,
                                         foreignIds: [String],
                                         times: [Date],
                                         completion: @escaping Completion<T>) -> Cancellable {
        return request(endpoint: ActivityEndpoint.get(foreignIds: foreignIds, times: times)) {
            Client.parseResultsResponse($0, inContainer: true, completion: completion)
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
    public func update(activities: [Activity], completion: @escaping StatusCodeCompletion) -> Cancellable {
        return update(activitiesContainer: ActivitiesContainer(activities), completion: completion)
    }
    
    /// Update activities data with the given activities container.
    ///
    /// - Note: When you update an activity, you must include the following fields both when adding and updating the activity:
    ///     - time
    ///     - foreignId
    /// - Note: It is not possible to update more than 100 activities per request with this method.
    /// - Note: When updating an activity any changes to the `feedIds` property are ignored.
    @discardableResult
    public func update(activitiesContainer: ActivitiesContainer, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: ActivityEndpoint.update(activitiesContainer), completion: { result in
            do {
                let response = try result.dematerialize()
                completion(.success(response.statusCode))
                
            } catch let error as ClientError {
                completion(.failure(error))
            } catch {
                completion(.failure(.unknownError(error)))
            }
        })
    }
}
