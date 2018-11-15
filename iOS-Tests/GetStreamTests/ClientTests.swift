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
    
    func testClient() {
        let baseURL = BaseURL(location: .europeWest)
        
        let moyaProvider = MoyaProvider<MultiTarget>(endpointClosure: { Client.endpointMapping($0, apiKey: "testAPIKey", baseURL: baseURL) },
                                                     stubClosure: MoyaProvider.immediatelyStub,
                                                     plugins: [AuthorizationMoyaPlugin(token: "test.token"),
                                                               NetworkLoggerPlugin(verbose: true)])
        
        let client = Client(moyaProvider: moyaProvider)
        let feedGroup = FeedGroup(feedSlug: "test", userId: "123")
        
        let expectFeed = expectation(description: "expecting a feed received")
        
        client.request(endpoint: FeedEndpoint.feed(feedGroup, pagination: .none)) { result in
            if case .success(let data) = result, let activities = data.json["results"] as? [String: Any] {
                XCTAssertEqual(activities.count, 3)
            } else if case .failure(let error) = result {
                XCTFail(error.localizedDescription)
            }
            
            expectFeed.fulfill()
        }
        
        wait(for: [expectFeed], timeout: TimeInterval(1))
    }
}
