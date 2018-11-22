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
        let secret = "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav"
        let token = Token(secret: secret)
        let jwtClaims: ClaimSet = try! JWT.decode(token, algorithm: .hs256(secret.data(using: .utf8).require()))
        XCTAssertEqual((jwtClaims["resource"] as? String).require(), Token.Resource.all.rawValue)
        XCTAssertEqual((jwtClaims["action"] as? String).require(), Token.Permission.all.rawValue)
        XCTAssertEqual((jwtClaims["feed_id"] as? String).require(), FeedId.any.description)
    }
}
