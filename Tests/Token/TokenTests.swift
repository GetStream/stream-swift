//
//  TokenTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 22/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import JWT
@testable import GetStream

class TokenTests: XCTestCase {

    func testGenerator() {
        let secretData = "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav".data(using: .utf8)!
        let token = Token(secretData: secretData)
        let jwtClaims: ClaimSet = try! JWT.decode(token, algorithm: .hs256(secretData))
        XCTAssertEqual(jwtClaims["resource"] as! String, Token.Resource.all.rawValue)
        XCTAssertEqual(jwtClaims["action"] as! String, Token.Permission.all.rawValue)
        XCTAssertEqual(jwtClaims["feed_id"] as! String, FeedId.any.description)
    }

    func testUserGenerator() {
        let secretData = "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav".data(using: .utf8)!
        let token = Token(secretData: secretData, userId: "eric")
        let jwtClaims: ClaimSet = try! JWT.decode(token, algorithm: .hs256(secretData))
        XCTAssertNil(jwtClaims["resource"])
        XCTAssertNil(jwtClaims["action"])
        XCTAssertNil(jwtClaims["feed_id"])
        XCTAssertEqual(jwtClaims["user_id"] as! String, "eric")
    }
}
