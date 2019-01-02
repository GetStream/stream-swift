//
//  UserTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 27/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

final class CustomUser: User {
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    var name: String
    
    init(id: String, name: String) {
        self.name = name
        super.init(id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try super.encode(to: encoder)
    }
}

class UserTests: TestCase {
    func testCreate() {
        let user = CustomUser(id: "test", name: "Eric Test")
        
        expect("create user") { test in
            client.create(user: user) {
                print($0)
                let created = try! $0.get()
                XCTAssertEqual(created.name, user.name)
                
                self.client.get(typeOf: CustomUser.self, userId: user.id) {
                    let loaded = try! $0.get()
                    XCTAssertEqual(loaded.name, user.name)
                    loaded.name = "Eric Updated"
                    XCTAssertNotEqual(loaded.name, user.name)
                    
                    self.client.update(user: loaded) {
                        let updated = try! $0.get()
                        XCTAssertEqual(updated.name, loaded.name)
                        
                        self.client.delete(userId: updated.id) {
                            XCTAssertEqual(try! $0.get(), 200)
                            test.fulfill()
                        }
                    }
                }
            }
        }
    }
}
