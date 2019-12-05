//
//  ExtensionsTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 20/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
@testable import GetStream

final class ExtensionsTests: XCTestCase {
    let decoder = JSONDecoder.default
    let encoder = JSONEncoder.default

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
""".data(using: .utf8)!

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
""".data(using: .utf8)!

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
""".data(using: .utf8)!
    
    // MARK: - Codable
    
    func testCodable() throws {
        let activity = try decoder.decode(SimpleActivity.self, from: defaultData)
        XCTAssertEqual(activity.actor, "eric")
        XCTAssertEqual(activity.time!, "2018-11-14T15:54:45.268000".streamDate!)
        let encodedData = try encoder.encode(activity)
        XCTAssertTrue(String(data: encodedData, encoding: .utf8)!.contains("2018-11-14T15:54:45.268"))
    }
    
    func testCodableInvalidData() {
        do {
            _ = try decoder.decode(SimpleActivity.self, from: badDefaultData)
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
    
    func testAnyCodable() throws {
        struct Test: Encodable {
            let value: String
        }
        
        let anyEncodable = AnyEncodable(Test(value: "test"))
        let jsonData = try encoder.encode(anyEncodable)
        XCTAssertEqual(String(data: jsonData, encoding: .utf8)!, "{\"value\":\"test\"}")
    }
    
    // MARK: - Test Date Formatter
    
    func testISO8601Codable() throws {
        let activity = try decoder.decode(SimpleActivity.self, from: iso8601Data)
        XCTAssertEqual(activity.actor, "eric")
        XCTAssertEqual(activity.time!, "2018-11-14T15:54:45.268000".streamDate!)
    }
    
    func testDateExtension() {
        let date = Date()
        let streamString = date.stream
        let streamDate = streamString.streamDate!
        XCTAssertEqual(streamDate, streamDate.stream.streamDate!)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        XCTAssertEqual(formatter.string(from: date), formatter.string(from: streamDate))
    }
    
    func testStreamTargetType() {
        struct Test: StreamTargetType {
            var path: String = ""
            var method: Moya.Method = Moya.Method.get
            var task: Task = .requestPlain
        }
        
        let test = Test()
        
        XCTAssertEqual(test.baseURL, URL(string: "https://getstream.io")!)
        XCTAssertEqual(test.headers?["X-Stream-Client"]!, "stream-swift-client-\(Client.version)")
        XCTAssertEqual(test.sampleData, Data())
    }
    
    func testSimpleCancellable() {
        let cancellable = SimpleCancellable()
        XCTAssertFalse(cancellable.isCancelled)
        cancellable.cancel()
        XCTAssertTrue(cancellable.isCancelled)
    }
}
