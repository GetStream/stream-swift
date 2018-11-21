//
//  ClientTests.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 14/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
@testable import GetStream

class ClientTests: XCTestCase {
    
    let baseURL = BaseURL(location: .europeWest)
    let feedId = FeedId(feedSlug: "test", userId: "123")
    
    lazy var provider = NetworkProvider(endpointClosure: { Client.endpointMapping($0, apiKey: "apiKey", baseURL: self.baseURL) },
                                        stubClosure: MoyaProvider.immediatelyStub,
                                        plugins: [AuthorizationMoyaPlugin(token: "test.token"),
                                                  NetworkLoggerPlugin(verbose: true)])
    
    lazy var client = Client(appId: "appId", networkProvider: provider)
    
    func testConstructor() {
        XCTAssertEqual(Client(apiKey: "", appId: "appId", token: "").appId, "appId")
        _ = Client(apiKey: "", appId: "appId", token: "", logsEnabled: true)
        _ = Client(apiKey: "", appId: "appId", token: "", callbackQueue: DispatchQueue.main)
    }
    
    func testGetEndpoint() {
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
    
    func testAddActivity() {
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
}
