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
    private let feedGroup: FeedGroup
    private let client: Client
    
    public init(_ feedGroup: FeedGroup, client: Client) {
        self.feedGroup = feedGroup
        self.client = client
    }
}

// MARK: - Add a new Activity

extension Feed {
    /// Add a new activity.
    @discardableResult
    public func add<T: ActivityProtocol>(_ activity: T,
                                         to feedGroup: FeedGroup,
                                         completion: @escaping Completion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.add(activity, feedGroup: feedGroup)) { [self] result in
            self.parseResponse(with: result, completion: completion)
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
    public mutating func feed(pagination: FeedPagination = .none, completion: @escaping Completion<Activity>) -> Cancellable {
        return feed(of: Activity.self, pagination: pagination, completion: completion)
    }
    
    /// Receive feed activities with a custom activity type.
    ///
    /// - Parameters:
    ///     - pagination: a pagination options.
    ///     - completion: a completion handler with Result of a custom activity type.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public func feed<T: ActivityProtocol>(of type: T.Type,
                                                   pagination: FeedPagination = .none,
                                                   completion: @escaping Completion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.feed(feedGroup, pagination: pagination)) { [self] result in
            self.parseResponse(with: result, completion: completion)
        }
    }
}

// MARK: - Parsing

extension Feed {
    private func parseResponse<T: Decodable>(with result: Result<Data, ClientError>, completion: @escaping Completion<T>) {
        if case .success(let data) = result {
            do {
                let container = try JSONDecoder.stream.decode(FeedResultsContainer<T>.self, from: data)
                completion(.success(container.results))
            } catch {
                completion(.failure(.jsonDecode(error)))
            }
        } else if case .failure(let error) = result {
            completion(.failure(error))
        }
    }
}

fileprivate struct FeedResultsContainer<T: Decodable>: Decodable {
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
