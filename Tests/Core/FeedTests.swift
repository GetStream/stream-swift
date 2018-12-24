//
//  FeedTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
import Result
@testable import GetStream

final class FeedTests: TestCase {
    
    func testFeed() {
        let feedId = FeedId(feedSlug: "s1", userId: "u1")
        XCTAssertEqual(feedId.together, "s1u1")
        XCTAssertEqual(FeedId(feedSlug: "empty", userId: "").togetherWithSlash, "empty")
        
        XCTAssertEqual(Feed(feedId, client: client).description, "s1:u1")
        XCTAssertEqual(client.flatFeed(feedSlug: "s2", userId: "u2").description, "s2:u2")
        XCTAssertEqual(client.flatFeed(feedSlug: "flat")!.description, "flat:eric")
        
        XCTAssertNil(Client(apiKey: "1",
                            appId: "2",
                            token: "3",
                            networkProvider: NetworkProvider(stubClosure: NetworkProvider.immediatelyStub))
            .flatFeed(feedSlug: "flat"))
    }
    
    func testFeedAdd() {
        expect("an activity") { test in
            let feed = client.flatFeed(feedSlug: "s", userId: "u")
            let activity = Activity(actor: "tester", verb: "add", object: "activity")
            
            feed.add(activity) { result in
                if case .success(let activities) = result, activities.count == 1, let first = activities.first {
                    XCTAssertEqual(first.actor, activity.actor)
                    XCTAssertEqual(first.verb, activity.verb)
                    XCTAssertEqual(first.object, activity.object)
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedRemoveById() {
        expect("activity removed") { test in
            let feed = client.flatFeed(feedSlug: "s", userId: "u")
            
            feed.remove(by: .test1) { result in
                if case .success(let activityId) = result {
                    XCTAssertEqual(activityId, UUID.test1.lowercasedString)
                    test.fulfill()
                }
            }
            
        }
    }
    
    func testFeedRemoveByForeignId() {
        expect("activity removed") { test in
            let feed = client.flatFeed(feedSlug: "s", userId: "u")
            
            feed.remove(by: "f1") { result in
                if case .success(let foreignId) = result {
                    XCTAssertEqual(foreignId, "f1")
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedGet() {
        expect("activities") { test in
            let feed = client.flatFeed(feedSlug: "s", userId: "u")
            
            feed.get(pagination: .limit(1), ranking: "popularity") { result in
                if case .success(let activities) = result, activities.count == 1 {
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedFollow() {
        expect("a code status") { test in
            let feed = client.flatFeed(feedSlug: "s1", userId: "u1")
            
            feed.follow(to: FeedId(feedSlug: "s2", userId: "u2")) { result in
                if case .success(let codeStatus) = result, codeStatus == 200 {
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedUnfollow() {
        let feed = client.flatFeed(feedSlug: "s1", userId: "u1")
        
        expect("a code status") { test in
            feed.unfollow(from: FeedId(feedSlug: "s2", userId: "u2")) { result in
                if case .success(let codeStatus) = result, codeStatus == 200 {
                    test.fulfill()
                }
            }
        }
        
        expect("a bad code status") { test in
            feed.unfollow(from: FeedId(feedSlug: "s2", userId: "u2"), keepHistory: true) { result in
                if case .failure(let clientError) = result, case .jsonInvalid = clientError {
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedFollowers() {
        expect("followers") { test in
            let feedId = FeedId(feedSlug: "s1", userId: "u1")
            client.flatFeed(feedId).followers(completion: { self.followerFollowing(feedId: feedId, test: test, result: $0) })
        }
    }
    
    func testFeedFollowing() {
        expect("following") { test in
            let feedId = FeedId(feedSlug: "s1", userId: "u1")
            client.flatFeed(feedId).following(filter: [FeedId(feedSlug: "s2", userId: "u2")],
                                          completion: { self.followerFollowing(feedId: feedId, test: test, result: $0) })
        }
    }
    
    private func followerFollowing(feedId: FeedId, test: XCTestExpectation, result: Result<[Follower], ClientError>) {
        if case .success(let followers) = result, followers.count == 1, let follower = followers.first {
            XCTAssertEqual(follower.feedId, feedId)
            XCTAssertEqual(follower.targetFeedId, FeedId(feedSlug: "s2", userId: "u2"))
            test.fulfill()
        }
    }
    
    // MARK: - FeedId tests

    func testFeedId() {
        XCTAssertEqual(FeedId(feedSlug: "s1", userId: "u1").description, "s1:u1")
        XCTAssertEqual(FeedId(feedSlug: "s2", userId: "").description, "s2")
    }
    
    func testFeedIds() {
        XCTAssertEqual([FeedId(feedSlug: "s1", userId: "u1"), FeedId(feedSlug: "s2", userId: "u2")].value, "s1:u1,s2:u2")
    }
    
    func testDecodeFeedId() throws {
        try testDecodeFeedId("", error: "Cannot initialize FeedId from an empty string")
        try testDecodeFeedId("123", error: "Cannot initialize FeedId from a currupted string: 123")
    }
    
    private func testDecodeFeedId(_ payload: String, error errorDescription: String) throws {
        struct Test: Decodable {
            let feedId: FeedId
        }
        
        do {
            _ = try JSONDecoder.stream.decode(Test.self, from: "{\"feedId\":\"\(payload)\"}".data(using: .utf8)!)
        } catch let error as DecodingError {
            if case .dataCorrupted(let context) = error {
                XCTAssertEqual(context.debugDescription, errorDescription)
            } else {
                throw error
            }
        }
    }
}
