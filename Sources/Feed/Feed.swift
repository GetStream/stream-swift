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

/// - feedSlug: the name of the feed group, for instance user, trending, flat, timeline etc. For example: flat, timeline
/// - userId: the owner of the given feed.
public typealias FeedId = (feedSlug: String, userId: String)

public struct Feed {
    private let feedId: FeedId
    private let client: Client
    
    private var feedCancelling: Moya.Cancellable?
    
    public init(_ feedId: FeedId, client: Client) {
        self.feedId = feedId
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
        
        let cancelling = client.request(endpoint: FeedEndpoint.feed(feedId, pagination: pagination)) { [self] result in
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
    private func parseFeed(_ data: Data, completion: @escaping Completion<Activity>) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            let container = try decoder.decode(FeedResultsContainer.self, from: data)
            completion(.success(container.results))
        } catch {
            completion(.failure(.jsonDecode(error)))
        }
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
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
