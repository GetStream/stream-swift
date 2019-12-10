//
//  NotificationFeedTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 24/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

class NotificationFeedTests: TestCase {
    lazy var notificationsFeed = Client.shared.notificationFeed(feedSlug: "notifications")

    func testNotioficationsFeed() {
        expect("get notifications") { test in
            notificationsFeed?.get(typeOf: SimpleActivity.self) { result in
                let notifications = try! result.get()
                
                XCTAssertEqual(notifications.results.count, 1)
                XCTAssertEqual(notifications.results.first!.isSeen, true)
                XCTAssertEqual(notifications.results.first!.isRead, false)
                XCTAssertEqual(notifications.results.first!.activitiesCount, 6)
                XCTAssertEqual(notifications.results.first!.activities.count, 6)
                XCTAssertEqual(notifications.results.first!.verb, "test")
                XCTAssertTrue(notifications.results.first!.group.hasPrefix("test_"))
                XCTAssertEqual(notifications.results.first!.activities.first!.verb, "test")
                
                test.fulfill()
            }
        }
    }
}
