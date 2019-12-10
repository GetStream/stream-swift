//
//  OGTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 24/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

class OGTests: TestCase {
    
    func testOG() {
        expect("get OpenGraph data") { test in
            let url = URL(string: "http://www.imdb.com/title/tt2084970/")!
            Client.shared.og(url: url) {
                let data = try! $0.get()
                XCTAssertEqual(data.title, "The Imitation Game (2014)")
                XCTAssertEqual(data.url, url)
                XCTAssertEqual(data.siteName, "IMDb")
                XCTAssertEqual(data.images!.count, 1)
                XCTAssertEqual(data.images!.first!.image,
                               "https://m.media-amazon.com/images/M/MV5BOTgwMzFiMWYtZDhlNS00ODNkLWJiODAtZDVhNzgyNzJhYjQ4L2ltYWdlXkEyXkFqcGdeQXVyNzEzOTYxNTQ@._V1_UY1200_CR87,0,630,1200_AL_.jpg")
                test.fulfill()
            }
        }
    }
}
