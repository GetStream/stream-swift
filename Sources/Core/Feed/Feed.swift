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

public struct Feed {
    private let feedId: FeedId
    private let client: Client
    
    public init(_ feedId: FeedId, client: Client) {
        self.feedId = feedId
        self.client = client
    }
}

extension Client {
    public func feed(feedSlug: String, userId: String) -> Feed {
        return feed(FeedId(feedSlug: feedSlug, userId: userId))
    }
    
    public func feed(_ feedIf: FeedId) -> Feed {
        return Feed(feedIf, client: self)
    }
}

// MARK: - Add a new Activity

extension Feed {
    /// Add a new activity.
    @discardableResult
    public func add<T: ActivityProtocol>(_ activity: T, completion: @escaping Completion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.add(activity, feedId: feedId)) { [self] result in
            self.parseResponse(result, completion: completion)
        }
    }
}

// MARK: - Delete a new Activity

extension Feed {
    /// Remove an activity by the activityId.
    @discardableResult
    public func remove(by activityId: UUID, completion: @escaping RemovedCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.deleteById(activityId, feedId: feedId)) { [self] result in
            self.parseRemovedResponse(result, completion: completion)
        }
    }
    
    /// Remove an activity by the foreignId.
    @discardableResult
    public func remove(by foreignId: String, completion: @escaping RemovedCompletion) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.deleteByForeignId(foreignId, feedId: feedId)) { [self] result in
            self.parseRemovedResponse(result, completion: completion)
        }
    }
}

// MARK: - Receive Feed Activities

extension Feed {
    /// Receive feed activities.
    ///
    /// - Parameters:
    ///     - pagination: a pagination options.
    ///     - completion: a completion handler with Result of Activity.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func get(pagination: FeedPagination = .none, completion: @escaping Completion<Activity>) -> Cancellable {
        return get(typeOf: Activity.self, pagination: pagination, completion: completion)
    }
    
    /// Receive feed activities with a custom activity type.
    ///
    /// - Parameters:
    ///     - pagination: a pagination options.
    ///     - completion: a completion handler with Result of a custom activity type.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func get<T: ActivityProtocol>(typeOf type: T.Type,
                                         pagination: FeedPagination = .none,
                                         completion: @escaping Completion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.get(feedId, pagination: pagination)) { [self] result in
            self.parseResponse(result, inContainer: true, completion: completion)
        }
    }
}

// MARK: - Parsing

extension Feed {
    private func parseResponse<T: Decodable>(_ result: ClientCompletionResult,
                                             inContainer: Bool = false,
                                             completion: @escaping Completion<T>) {
        if case .success(let response) = result {
            do {
                if inContainer {
                    let container = try JSONDecoder.stream.decode(ResultsContainer<T>.self, from: response.data)
                    completion(.success(container.results))
                } else {
                    let object = try JSONDecoder.stream.decode(T.self, from: response.data)
                    completion(.success([object]))
                }
            } catch {
                completion(.failure(.jsonDecode(error)))
            }
        } else if case .failure(let error) = result {
            completion(.failure(error))
        }
    }
    
    private func parseRemovedResponse(_ result: ClientCompletionResult, completion: @escaping RemovedCompletion) {
        if case .success(let response) = result, let json = (try? response.mapJSON()) as? JSON {
            completion(.success(json["removed"] as? String))
        } else if case .failure(let error) = result {
            completion(.failure(error))
        }
    }
}

fileprivate struct ResultsContainer<T: Decodable>: Decodable {
    private enum CodingKey: String, Swift.CodingKey {
        case results
        case next
        case duration
    }
    
    let results: [T]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        results = try container.decode([T].self, forKey: .results)
    }
}
