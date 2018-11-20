//
//  ExtensionsTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 20/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Require
@testable import GetStream

final class ExtensionsTests: XCTestCase {
    let decoder = JSONDecoder.Stream.default
    let encoder = JSONEncoder.Stream.default
    let decoderISO8601 = JSONDecoder.Stream.iso8601

    let defaultData = """
{
    "actor":"eric",
    "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
    "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
    "object":"Hello world 3",
    "origin":null,
    "target":"",
    "time":"2018-11-14T15:54:45.268000",
    "to":["timeline:jessica"],
    "verb":"tweet"
}
""".data(using: .utf8).require()

    let iso8601Data = """
{
    "actor":"eric",
    "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
    "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
    "object":"Hello world 3",
    "origin":null,
    "target":"",
    "time":"2018-11-14T15:54:45.268000Z",
    "to":["timeline:jessica"],
    "verb":"tweet"
}
""".data(using: .utf8).require()

    let badDefaultData = """
{
    "actor":"eric",
    "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
    "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
    "object":"Hello world 3",
    "origin":null,
    "target":"",
    "time":"2018-11-14",
    "to":["timeline:jessica"],
    "verb":"tweet"
}
""".data(using: .utf8).require()
    
    func testCodable() {
        do {
            let activity = try decoder.decode(Activity.self, from: defaultData)
            XCTAssertEqual(activity.actor, "eric")
            
            if let time = activity.time {
                XCTAssertEqual(time, "2018-11-14T15:54:45.268000".streamDate.require())
                
                let encodedData = try encoder.encode(activity)
                
                if let dataString = String(data: encodedData, encoding: .utf8) {
                    XCTAssertTrue(dataString.contains("2018-11-14T15:54:45.268"))
                } else {
                    XCTFail("❌")
                }
            } else {
                XCTFail("❌ Failed decode date property of Activity")
            }
        } catch {
            XCTFail("❌ \(error.localizedDescription)")
        }
    }
    
    func testCodableInvalidData() {
        do {
            _ = try decoder.decode(Activity.self, from: badDefaultData)
            XCTFail("❌ Empty json data check")
            
        } catch let error as DecodingError {
            if case .dataCorrupted(let context) = error {
                XCTAssertEqual(context.debugDescription, "Invalid date: 2018-11-14")
            } else {
                XCTFail("❌")
            }
        } catch {
            XCTFail("❌")
        }
    }
    
    func testISO8601Codable() {
        do {
            let activity = try decoderISO8601.decode(Activity.self, from: iso8601Data)
            XCTAssertEqual(activity.actor, "eric")
            
            if let time = activity.time {
                XCTAssertEqual(time, "2018-11-14T15:54:45.268000".streamDate.require())
            } else {
                XCTFail("❌ Failed decode date property of Activity")
            }
        } catch {
            XCTFail("❌ \(error.localizedDescription)")
        }
    }
    
    func testDateExtension() {
        let date = Date()
        let streamString = date.stream
        let streamDate = streamString.streamDate.require()
        XCTAssertEqual(streamDate, streamDate.stream.streamDate.require())
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        XCTAssertEqual(formatter.string(from: date), formatter.string(from: streamDate))
    }
}
