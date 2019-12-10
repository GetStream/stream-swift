//
//  TestCase.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

class TestCase: XCTestCase {
    
    override class func setUp() {
        let provider = NetworkProvider(stubClosure: NetworkProvider.immediatelyStub)
        Client.config = .init(apiKey: "apiKey", appId: "appId", networkProvider: provider)
        
        if User.current == nil {
            setupUser(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZXJpYyJ9.20YPOjP1-HtwKH7SH3k5CgLLLrhLCLaKDnb8XuiU7oA")
        }
    }
    
    class func setupUser(token: Token, shouldFail: Bool = false) {
        Client.shared.setupUser(token: token) { result in
            if let user = try? result.get(), Client.shared.currentUserId == user.id {
                if shouldFail {
                    XCTFail("User setup should fail, but got user: \(user)")
                } else {
                    XCTAssertEqual(user.id, Client.shared.currentUserId ?? "unwrapped")
                }
            } else if let error = result.error {
                if !shouldFail {
                    XCTFail("User setup failed with error: \(error)")
                }
            } else if !shouldFail {
                XCTFail("User setup failed: \(result)")
            }
        }
    }
    
    func expect(_ description: String, timeout: TimeInterval = TimeInterval(1), callback: (_ test: XCTestExpectation) -> Void) {
        let test = expectation(description: "⏳ expecting \(description)")
        callback(test)
        wait(for: [test], timeout: timeout)
    }
}
