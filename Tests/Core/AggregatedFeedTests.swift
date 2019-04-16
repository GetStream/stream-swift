//
//  AggregatedFeedTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 24/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

class AggregatedFeedTests: TestCase {
    lazy var aggregated = client.aggregatedFeed(feedSlug: "aggregated")

    func testAggregated() {
        XCTAssertNotNil(aggregated)
        XCTAssertEqual(aggregated!.feedId, client.aggregatedFeed(feedSlug: "aggregated", userId: "eric").feedId)
        
        expect("get aggregated") { test in
            aggregated!.get(typeOf: SimpleActivity.self) { result in
                let groups = try! result.get()
                XCTAssertEqual(groups.results.count, 2)
                XCTAssertEqual(groups.results.first!.verb, "verb")
                XCTAssertEqual(groups.results.first!.activitiesCount, 2)
                XCTAssertEqual(groups.results.first!.activities.count, 2)
                XCTAssertEqual(groups.results.first!.actorsCount, 1)
                XCTAssertTrue(groups.results.first!.group.hasPrefix("verb_"))
                XCTAssertEqual(groups.results.first!.activities.first!.actor, "Me")
                XCTAssertEqual(groups.results.first!.activities.first!.verb, "verb")
                XCTAssertEqual(groups.results.first!.activities.first!.object, "Message")
                
                test.fulfill()
            }
        }
    }
    
    func testBadJSON() {
        let aggregated = client.aggregatedFeed(feedSlug: "bad")
        
        expect("get bad aggregated") { test in
            aggregated!.get { result in
                if case .failure(let clientError) = result, case .network = clientError {
                    test.fulfill()
                }
            }
        }
    }
}
