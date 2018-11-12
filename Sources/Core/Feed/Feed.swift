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
    
    private var feedCancelling: Moya.Cancellable?
    
    public init(_ feedGroup: FeedGroup, client: Client) {
        self.feedGroup = feedGroup
        self.client = client
    }
}

// MARK: - Activities

extension Feed {
    /// Retrieve feed activities.
    ///
    /// - Parameters:
    ///     - pagination: a pagination options
    ///     - completion: a completion handler
    /// - Returns:
    ///     - a cancellable object to cancel the request
    @discardableResult
    public mutating func feed(pagination: FeedPagination = .none, completion: @escaping Completion<Activity>) -> Cancellable {
        if let feedCancelling = feedCancelling, !feedCancelling.isCancelled {
            feedCancelling.cancel()
        }
        
        let cancelling = client.request(endpoint: FeedEndpoint.feed(feedGroup, pagination: pagination)) { [self] result in
            if case .success(let data) = result {
                self.parseFeed(data, completion: completion)
            } else if case .failure(let error) = result {
                completion(.failure(error))
            }
        }
        
        feedCancelling = cancelling
        
        return cancelling
    }
}

// MARK: - Parsing

extension Feed {
    // FIXME: private
    public func parseFeed(_ data: Data, completion: @escaping Completion<Activity>) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .stream
            let container = try decoder.decode(FeedResultsContainer.self, from: data)
            completion(.success(container.results))
        } catch {
            completion(.failure(.jsonDecode(error)))
        }
    }
}

fileprivate struct FeedResultsContainer: Decodable {
    enum CodingKey: String, Swift.CodingKey {
        case results
        case next
        case duration
    }
    
    let results: [Activity]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        results = try container.decode([Activity].self, forKey: .results)
    }
}
