//
//  TestCase.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

extension Client {
    static var test: Client {
        let provider = NetworkProvider(stubClosure: NetworkProvider.immediatelyStub)
        let client = Client(apiKey: "apiKey",
                            appId: "appId",
                            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZXJpYyJ9.20YPOjP1-HtwKH7SH3k5CgLLLrhLCLaKDnb8XuiU7oA",
                            networkProvider: provider)
        return client
    }
}

class TestCase: XCTestCase {
    lazy var client = Client.test
    
    func expect(_ description: String, callback: (_ test: XCTestExpectation) -> Void) {
        let test = expectation(description: "⏳ expecting \(description)")
        callback(test)
        wait(for: [test], timeout: TimeInterval(1))
    }
}
