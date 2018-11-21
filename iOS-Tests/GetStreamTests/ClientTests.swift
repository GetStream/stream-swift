//
//  ClientTests.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 14/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
import Require
@testable import GetStream

extension UUID {
    static let test1: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001").require()
    static let test2: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000002").require()
}

class ClientTests: XCTestCase {
    
    let baseURL = BaseURL(location: .europeWest)
    let feedId = FeedId(feedSlug: "test", userId: "123")
    
    lazy var provider = NetworkProvider(endpointClosure: { Client.endpointMapping($0, apiKey: "apiKey", baseURL: self.baseURL) },
                                        stubClosure: MoyaProvider.immediatelyStub,
                                        plugins: [AuthorizationMoyaPlugin(token: "test"),
                                                  NetworkLoggerPlugin(verbose: true)])
    
    lazy var client = Client(appId: "appId", networkProvider: provider)
    
    func testConstructor() {
        let client = Client(apiKey: "", appId: "appId", token: "")
        XCTAssertEqual(client.description, "GetStream Client v.\(Client.version) appId: appId")
        _ = Client(apiKey: "", appId: "appId", token: "", logsEnabled: true)
        _ = Client(apiKey: "", appId: "appId", token: "", callbackQueue: DispatchQueue.main)
    }
    
    func testFeedEndpointGet() {
        let expectFeed = expectation(description: "expecting a feed response")
        
        client.request(endpoint: FeedEndpoint.get(feedId, pagination: .none, ranking: "", markOption: .none)) { result in
            if case .success(let response) = result,
                let json = (try? response.mapJSON()) as? JSON,
                let activities = json["results"] as? [Any] {
                XCTAssertEqual(activities.count, 3)
            } else if case .failure(let error) = result {
                XCTFail("❌ \(error.localizedDescription)")
            } else {
                XCTFail("❌ Bad data")
            }
            
            expectFeed.fulfill()
        }
        
        wait(for: [expectFeed], timeout: TimeInterval(1))
    }
    
    func testFeedEndpointAddActivity() {
        let expectFeed = expectation(description: "expecting a feed response")
        let activity = Activity(actor: "tester", verb: "test", object: "add activity")
        
        client.request(endpoint: FeedEndpoint.add(activity, feedId: feedId)) { result in
            if case .success(let response) = result,
                let json = (try? response.mapJSON()) as? JSON {
                XCTAssertEqual(json["actor"] as! String, activity.actor)
                XCTAssertEqual(json["verb"] as! String, activity.verb)
                XCTAssertEqual(json["object"] as! String, activity.object)
            } else if case .failure(let error) = result {
                XCTFail("❌ \(error.localizedDescription)")
            } else {
                XCTFail("❌ Bad data")
            }
            
            expectFeed.fulfill()
        }
        
        wait(for: [expectFeed], timeout: TimeInterval(1))
    }
    
    func testClientActivityGet() {
        let expectFeed = expectation(description: "expecting a activity response")
        
        client.get(typeOf: Activity.self, activityIds: [.test1, .test2]) { result in
            if case .success(let activities) = result {
                XCTAssertEqual(activities.count, 2)
                XCTAssertEqual(activities[0].id.require(), .test1)
                XCTAssertEqual(activities[1].id.require(), .test2)
            } else {
                XCTFail("❌ Bad data")
            }
            
            expectFeed.fulfill()
        }
        
        wait(for: [expectFeed], timeout: TimeInterval(1))
    }
    
    func testJSONInvalid() {
        failRequests(clientError: .jsonInvalid)
    }
    
    func testFailedMapDataToJSON() {
        failRequests(clientError: .network("Failed to map data to JSON."))
    }
    
    func testExceptionInJSON() {
        failRequests(clientError: .server(.init(json: ["exception": 0])))
    }
    
    func failRequests(clientError: ClientError) {
        let expect = expectation(description: "expecting \(clientError.localizedDescription)")
        let activity = Activity(actor: clientError.localizedDescription, verb: "", object: "")
        
        client.request(endpoint: FeedEndpoint.add(activity, feedId: feedId)) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.localizedDescription, clientError.localizedDescription)
            } else {
                XCTFail("❌ Shouldn't be success")
            }
            
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: TimeInterval(1))
    }
    
    func testFeedPagination() {
        var endpoint = FeedEndpoint.get(feedId, pagination: .none, ranking: "", markOption: .none)
        
        guard case .requestPlain = endpoint.task else {
            XCTFail("❌")
            return
        }
        
        // with limit 5.
        endpoint = FeedEndpoint.get(feedId, pagination: .limit(5), ranking: "", markOption: .none)
        
        guard case .requestParameters(let limitParameters, _) = endpoint.task else {
            XCTFail("❌")
            return
        }
        
        XCTAssertEqual(limitParameters as! [String: Int], ["limit": 5])
        
        // with offset and limit
        endpoint = FeedEndpoint.get(feedId, pagination: .offset(1, limit: 1), ranking: "", markOption: .none)
        
        guard case .requestParameters(let offsetParameters, _) = endpoint.task else {
            XCTFail("❌")
            return
        }
        
        XCTAssertEqual(offsetParameters as! [String: Int], ["offset": 1, "limit": 1])
        
        // with great then id and limit
        let someId = "someId"
        endpoint = FeedEndpoint.get(feedId, pagination: .greaterThan(id: someId, limit: 3), ranking: "", markOption: .none)
        
        guard case .requestParameters(let idParameters, _) = endpoint.task else {
            XCTFail("❌")
            return
        }
        
        XCTAssertEqual(idParameters["id_gt"] as! String, someId)
        XCTAssertEqual(idParameters["limit"] as! Int, 3)
    }
    
    func testRateLimit() {
        let response = Response(statusCode: 200, data: Data())
        XCTAssertNil(Client.RateLimit(response: response))
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let httpResponse = HTTPURLResponse(url: baseURL.url,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["x-ratelimit-limit": "20",
                                                          "x-ratelimit-remaining": "10",
                                                          "x-ratelimit-reset": String(timestamp)])
        let rateLimit = Client.RateLimit(response: Response(statusCode: 200, data: Data(), response: httpResponse))
        XCTAssertNotNil(rateLimit)
        
        if let rateLimit = rateLimit {
            XCTAssertEqual(rateLimit.limit, 20)
            XCTAssertEqual(rateLimit.remaining, 10)
            XCTAssertEqual(rateLimit.resetDate, Date(timeIntervalSince1970: TimeInterval(timestamp)))
        }
    }
    
    func testClientError() {
        let info = ClientError.Info(json: ["detail": "DETAIL", "code": 1, "status_code": 2, "exception": "EXCEPTION"])
        XCTAssertEqual(info.description, "EXCEPTION[1] Status Code: 2, DETAIL")
        
        let emptyInfo = ClientError.Info(json: ["empty":"json"])
        XCTAssertEqual(emptyInfo.description, "JSON response [\"empty\": \"json\"]")
        
        ClientError.warning(for: [], missedParameter: "test")
        
        let unknownError = ClientError.unknown
        XCTAssertEqual(unknownError.localizedDescription, "Unexpected behaviour")
        XCTAssertEqual(ClientError.unknownError(unknownError.localizedDescription).localizedDescription,
                       "Unexpected behaviour with error: Unexpected behaviour")
        XCTAssertEqual(ClientError.jsonEncode("test").localizedDescription, "JSON encoding error: test")
        XCTAssertEqual(ClientError.jsonDecode("test", data: Data()).localizedDescription, "JSON decoding error: test. Data: 0 bytes")
    }
}
