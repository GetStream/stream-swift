//
//  CollectionTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 24/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

final class Food: CollectionObject {
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    var name: String
    
    init(name: String, id: String? = nil) {
        self.name = name
        super.init(collectionName: "food", id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name)
        try super.init(from: decoder)
    }
    
    required init(collectionName: String, id: String? = nil) {
        name = ""
        super.init(collectionName: collectionName, id: id)
    }
    
    override func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try super.encode(to: encoder)
    }
}

class CollectionTests: TestCase {
    
    func testAdd() {
        let burger = Food(name: "Burger", id: "123")
        XCTAssertEqual(burger.referenceId, "SO:food:123")
        
        expect("add collection object") { test in
            Client.shared.add(collectionObject: burger) { result in
                if let addedBurger = try? result.get() {
                    XCTAssertEqual(addedBurger.collectionName, "food")
                    XCTAssertEqual(addedBurger.foreignId, "food:123")
                    XCTAssertEqual(addedBurger.name, "Burger")
                } else {
                    XCTFail("Add collection object: \(result)")
                }
                
                test.fulfill()
            }
        }
    }
    
    func testGet() {
        expect("get collection object") { test in
            Client.shared.get(typeOf: Food.self, collectionName: "test", collectionObjectId: "obj") { result in
                let burger = try! result.get()
                XCTAssertEqual(burger.id, "123")
                XCTAssertEqual(burger.collectionName, "food")
                XCTAssertEqual(burger.name, "Burger")
                test.fulfill()
            }
        }
    }
    
    func testUpdate() {
        let burger = Food(name: "Burger2", id: "123")
        
        expect("update collection object") { test in
            Client.shared.update(collectionObject: burger) { result in
                let addedBurger = try! result.get()
                XCTAssertEqual(addedBurger.name, "Burger2")
                test.fulfill()
            }
        }
    }
    
    func testDelete() {
        expect("bad delete collection object") { test in
            let burger = Food(name: "Burger")
            XCTAssertEqual(burger.referenceId, "SO:food")
            Client.shared.delete(collectionObject: burger) { result in
                if case .failure(let error) = result, case .jsonInvalid = error {
                    test.fulfill()
                }
            }
        }
        
        expect("delete collection object") { test in
            let burger = Food(name: "Burger", id: "123")
            
            Client.shared.delete(collectionObject: burger) { result in
                let status = try! result.get()
                XCTAssertEqual(status, 200)
                test.fulfill()
            }
        }
    }
}
