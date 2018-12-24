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
    let client = Client.test
    lazy var notificationsFeed = client.notificationFeed(feedSlug: "notifications")

    func testNotioficationsFeed() {
        expect("get notifications") { test in
            notificationsFeed?.get(completion: { result in
                let notifications = try! result.dematerialize()
                
                XCTAssertEqual(notifications.count, 1)
                XCTAssertEqual(notifications.first!.isSeen, true)
                XCTAssertEqual(notifications.first!.isRead, false)
                XCTAssertEqual(notifications.first!.activitiesCount, 6)
                XCTAssertEqual(notifications.first!.activities.count, 6)
                XCTAssertEqual(notifications.first!.verb, "test")
                XCTAssertTrue(notifications.first!.group.hasPrefix("test_"))
                XCTAssertEqual(notifications.first!.activities.first!.verb, "test")
                
                test.fulfill()
            })
        }
    }
}
