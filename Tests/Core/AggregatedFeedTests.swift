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
            aggregated!.get { result in
                let groups = try! result.dematerialize()
                XCTAssertEqual(groups.count, 2)
                XCTAssertEqual(groups.first!.verb, "verb")
                XCTAssertEqual(groups.first!.activitiesCount, 2)
                XCTAssertEqual(groups.first!.activities.count, 2)
                XCTAssertEqual(groups.first!.actorsCount, 1)
                XCTAssertTrue(groups.first!.group.hasPrefix("verb_"))
                XCTAssertEqual(groups.first!.activities.first!.actor, "Me")
                XCTAssertEqual(groups.first!.activities.first!.verb, "verb")
                XCTAssertEqual(groups.first!.activities.first!.object, "Message")
                
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
