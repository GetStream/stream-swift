//
//  TestCase.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest

class TestCase: XCTestCase {
    func expect(_ description: String, callback: (_ test: XCTestExpectation) -> Void) {
        let test = expectation(description: "⏳ expecting \(description)")
        callback(test)
        wait(for: [test], timeout: TimeInterval(1))
    }
}
