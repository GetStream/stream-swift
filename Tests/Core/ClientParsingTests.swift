//
//  ClientParsingTests.swift
//  GetStream-iOS Tests
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
@testable import GetStream

class ClientParsingTests: TestCase {
    let queue = DispatchQueue.main

    func testResultsErrors() {
        let response = Response(statusCode: 200, data: Data())
        let responseResult: ClientCompletionResult = .success(response)
        
        expect("error json decode") { test in
            let completion: ActivityCompletion<Activity> = { result in
                if case .failure(let clientError) = result, case .jsonDecode = clientError {
                    test.fulfill()
                }
            }
            
            responseResult.parse(queue, completion)
        }
        
        expect("error result") { test in
            let completion: ActivitiesCompletion<Activity> = { result in
                if case .failure(let clientError) = result, case .unknownError = clientError {
                    test.fulfill()
                }
            }
            
            ClientCompletionResult.failure(ClientError.unknownError("", nil)).parse(queue, completion)
        }
    }
    
    func testRemovedErrors() {
        let response = Response(statusCode: 200, data: Data())
        let responseResult: ClientCompletionResult = .success(response)
        
        expect("error json decode") { test in
            responseResult.parseRemoved(queue) { result in
                if case .failure(let clientError) = result, case .jsonDecode = clientError {
                    test.fulfill()
                }
            }
        }
        
        expect("error result") { test in
            ClientCompletionResult.failure(ClientError.unknownError("", nil)).parseRemoved(queue) { result in
                if case .failure(let clientError) = result, case .unknownError = clientError {
                    test.fulfill()
                }
            }
        }
    }
}
