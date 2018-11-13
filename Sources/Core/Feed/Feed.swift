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
    
    /// Receive feed activities with custom subclass of Activity.
    ///
    /// - Parameters:
    ///     - pagination: a pagination options.
    ///     - completion: a completion handler with Result of custom subclass of Activity.
    /// - Returns:
    ///     - a cancellable object to cancel the request.
    @discardableResult
    public mutating func feed<T: ActivityProtocol>(of type: T.Type,
                                                   pagination: FeedPagination = .none,
                                                   completion: @escaping Completion<T>) -> Cancellable {
        return client.request(endpoint: FeedEndpoint.feed(feedGroup, pagination: pagination)) { [self] result in
            if case .success(let data) = result {
                self.parseFeed(data, completion: completion)
            } else if case .failure(let error) = result {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Parsing

extension Feed {
    private func parseFeed<T: Decodable>(_ data: Data, completion: @escaping Completion<T>) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .stream
            let container = try decoder.decode(FeedResultsContainer<T>.self, from: data)
            completion(.success(container.results))
        } catch {
            completion(.failure(.jsonDecode(error)))
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
