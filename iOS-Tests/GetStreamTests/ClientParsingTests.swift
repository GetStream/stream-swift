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
    
    func testResultsErrors() {
        let response = Response(statusCode: 200, data: Data())
        let responseResult: ClientCompletionResult = .success(response)
        
        expect("error json decode") { test in
            Client.parseResultsResponse(responseResult) { (result: ActivitiesResult<Activity>) in
                if case .failure(let clientError) = result, case .jsonDecode = clientError {
                    test.fulfill()
                }
            }
        }
        
        expect("error result") { test in
            Client.parseResultsResponse(.failure(ClientError.unknown)) { (result: ActivitiesResult<Activity>) in
                if case .failure(let clientError) = result, case .unknown = clientError {
                    test.fulfill()
                }
            }
        }
    }
    
    func testFollowersErrors() {
        let response = Response(statusCode: 200, data: Data())
        let responseResult: ClientCompletionResult = .success(response)
        
        expect("error json decode") { test in
            Client.parseFollowersResponse(responseResult) { result in
                if case .failure(let clientError) = result, case .unknownError = clientError {
                    test.fulfill()
                }
            }
        }
        
        expect("error result") { test in
            Client.parseFollowersResponse(.failure(ClientError.unknown)) { result in
                if case .failure(let clientError) = result, case .unknown = clientError {
                    test.fulfill()
                }
            }
        }
    }
    
    func testRemovedErrors() {
        let response = Response(statusCode: 200, data: Data())
        let responseResult: ClientCompletionResult = .success(response)
        
        expect("error json decode") { test in
            Client.parseRemovedResponse(responseResult) { result in
                if case .failure(let clientError) = result, case .jsonDecode = clientError {
                    test.fulfill()
                }
            }
        }
        
        expect("error result") { test in
            Client.parseRemovedResponse(.failure(ClientError.unknown)) { result in
                if case .failure(let clientError) = result, case .unknown = clientError {
                    test.fulfill()
                }
            }
        }
    }
}
