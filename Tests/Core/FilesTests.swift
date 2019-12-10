//
//  FilesTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 24/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import GetStream

class FilesTests: TestCase {
    
    let data = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==")!
    
    lazy var image = Image(data: data)!
    
    func testUpload() {
        expect("upload file") { test in
            let file = File(name: "test", data: data)
            Client.shared.upload(file: file) {
                XCTAssertEqual(try! $0.get(), URL(string: "http://uploaded.getstream.io/test")!)
                test.fulfill()
            }
        }
    }
    
    func testDelete() {
        expect("delete file") { test in
            Client.shared.delete(fileURL: URL(string: "http://uploaded.getstream.io/test")!) {
                XCTAssertEqual(try! $0.get(), 200)
                test.fulfill()
            }
        }
        
        expect("delete image") { test in
            Client.shared.delete(imageURL: URL(string: "http://images.getstream.io/test")!) {
                XCTAssertEqual(try! $0.get(), 200)
                test.fulfill()
            }
        }
    }
    
    func testUploadImage() {
        expect("upload image") { test in
            let file = File(name: "jpg", jpegImage: image)!
            Client.shared.upload(image: file) {
                XCTAssertEqual(try! $0.get(), URL(string: "http://images.getstream.io/jpg")!)
                
                let file = File(name: "png", pngImage: self.image)!
                Client.shared.upload(image: file) {
                    XCTAssertEqual(try! $0.get(), URL(string: "http://images.getstream.io/png")!)
                    test.fulfill()
                }
            }
        }
    }
    
    func testImageProcess() {
        expect("process image") { test in
            let process = ImageProcess(url: URL(string: "http://images.getstream.io/jpg")!, width: 100, height: 100)
            
            Client.shared.resizeImage(imageProcess: process, completion: {
                XCTAssertEqual(try! $0.get(), URL(string: "http://images.getstream.io/jpg?crop=center&h=100&w=100&resize=clip&url=http://images.getstream.io/jpg")!)
                test.fulfill()
            })
        }
        
        expect("bad process image") { test in
            let process = ImageProcess(url: URL(string: "http://images.getstream.io/jpg")!, width: 1, height: 0)
            
            Client.shared.resizeImage(imageProcess: process, completion: {
                if case .failure(let clientError) = $0, case .parameterInvalid = clientError {
                    test.fulfill()
                }
            })
        }
        
        expect("bad process image") { test in
            let process = ImageProcess(url: URL(string: "http://images.getstream.io/jpg")!, width: 0, height: 1)
            
            Client.shared.resizeImage(imageProcess: process, completion: {
                if case .failure(let clientError) = $0, case .parameterInvalid = clientError {
                    test.fulfill()
                }
            })
        }
    }
}
