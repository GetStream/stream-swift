//
//  FeedTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
@testable import GetStream

typealias UserFoodActivity = EnrichedActivity<CustomUser, Food, DefaultReaction>

final class FeedTests: TestCase {
    
    func testFeed() {
        let feedId = FeedId(feedSlug: "s1", userId: "u1")
        XCTAssertEqual(feedId.together, "s1u1")
        XCTAssertEqual(FeedId(feedSlug: "empty", userId: "").togetherWithSlash, "empty")
        
        XCTAssertEqual(Feed(feedId).description, "s1:u1")
        XCTAssertEqual(Client.shared.flatFeed(feedSlug: "s2", userId: "u2").description, "s2:u2")
        XCTAssertEqual(Client.shared.flatFeed(feedSlug: "flat")!.description, "flat:eric")
    }
    
    func testFeedAdd() {
        expect("an activity") { test in
            let feed = Client.shared.flatFeed(feedSlug: "s", userId: "u")
            let activity = SimpleActivity(actor: "tester", verb: "add", object: "activity")
            
            feed.add(activity) { result in
                if case .success(let resultActivity) = result {
                    XCTAssertEqual(resultActivity.actor, activity.actor)
                    XCTAssertEqual(resultActivity.verb, activity.verb)
                    XCTAssertEqual(resultActivity.object, activity.object)
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedRemoveById() {
        expect("activity removed") { test in
            let feed = Client.shared.flatFeed(feedSlug: "s", userId: "u")
            
            feed.remove(activityId: .test1) { result in
                if case .success(let activityId) = result {
                    XCTAssertEqual(activityId, String.test1)
                    test.fulfill()
                }
            }
            
        }
    }
    
    func testFeedRemoveByForeignId() {
        expect("activity removed") { test in
            let feed = Client.shared.flatFeed(feedSlug: "s", userId: "u")
            
            feed.remove(foreignId: "f1") { result in
                if case .success(let foreignId) = result {
                    XCTAssertEqual(foreignId, "f1")
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedGet() {
        expect("activities") { test in
            let feed = Client.shared.flatFeed(feedSlug: "s", userId: "u")
            
            feed.get(typeOf: SimpleActivity.self, pagination: .limit(1), ranking: "popularity") { result in
                if case .success(let response) = result, response.results.count == 1 {
                    test.fulfill()
                }
            }
        }
    }
    
    func testAddEnrichedActivity() {
        expect("add an enriched activity") { test in
            let feed = Client.shared.flatFeed(feedSlug: "s", userId: "u")
            let user = CustomUser(id: "eric", name: "Eric")
            let burger = Food(name: "Burger", id: "burger")
            let activity = UserFoodActivity(actor: user, verb: "eat", object: burger)
            
            feed.add(activity) { result in
                if case .success(let resultActivity) = result {
                    XCTAssertEqual(resultActivity.actor.name, activity.actor.name)
                    XCTAssertEqual(resultActivity.verb, activity.verb)
                    XCTAssertEqual(resultActivity.object.name, activity.object.name)
                    test.fulfill()
                }
            }
        }
    }
    
    func testGetEnrichedActivity() {
        expect("get an enriched activity") { test in
            let feed = Client.shared.flatFeed(feedSlug: "enrich", userId: "u")
            
            feed.get(typeOf: UserFoodActivity.self) { result in
                let activity = try! result.get().results.first!
                XCTAssertEqual(activity.actor.name, "Eric")
                XCTAssertEqual(activity.verb, "eat")
                XCTAssertEqual(activity.object.name, "Burger")
                test.fulfill()
            }
        }
    }

    // MARK: - Following
    
    func testFeedFollow() {
        expect("a code status") { test in
            let feed = Client.shared.flatFeed(feedSlug: "s1", userId: "u1")
            
            feed.follow(toTarget: FeedId(feedSlug: "s2", userId: "u2")) { result in
                if case .success(let codeStatus) = result, codeStatus == 200 {
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedUnfollow() {
        let feed = Client.shared.flatFeed(feedSlug: "s1", userId: "u1")
        
        expect("a code status") { test in
            feed.unfollow(fromTarget: FeedId(feedSlug: "s2", userId: "u2")) { result in
                if case .success(let codeStatus) = result, codeStatus == 200 {
                    test.fulfill()
                }
            }
        }
        
        expect("a bad code status") { test in
            feed.unfollow(fromTarget: FeedId(feedSlug: "s2", userId: "u2"), keepHistory: true) { result in
                if case .failure(let clientError) = result, case .jsonInvalid = clientError {
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedFollowers() {
        expect("followers") { test in
            let feedId = FeedId(feedSlug: "s1", userId: "u1")
            Client.shared.flatFeed(feedId).followers(completion: { self.followerFollowing(feedId: feedId, test: test, result: $0) })
        }
    }
    
    func testFeedFollowing() {
        expect("following") { test in
            let feedId = FeedId(feedSlug: "s1", userId: "u1")
            Client.shared.flatFeed(feedId).following(filter: [FeedId(feedSlug: "s2", userId: "u2")],
                                          completion: { self.followerFollowing(feedId: feedId, test: test, result: $0) })
        }
    }
    
    private func followerFollowing(feedId: FeedId,
                                   test: XCTestExpectation,
                                   result: Result<GetStream.Response<Follower>, ClientError>) {
        if case .success(let response) = result, response.results.count == 1, let follower = response.results.first {
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
            _ = try JSONDecoder.default.decode(Test.self, from: "{\"feedId\":\"\(payload)\"}".data(using: .utf8)!)
        } catch let error as DecodingError {
            if case .dataCorrupted(let context) = error {
                XCTAssertEqual(context.debugDescription, errorDescription)
            } else {
                throw error
            }
        }
    }
}
