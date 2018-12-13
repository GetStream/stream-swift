//
//  Result+ParseResponse.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

extension Result where Value == Response, Error == ClientError {
    
    func parseStatusCode(completion: @escaping StatusCodeCompletion) {
        do {
            let response = try result.dematerialize()
            completion(.success(response.statusCode))
        } catch {
            if let clientError = error as? ClientError {
                completion(.failure(clientError))
            }
        }
    }
}
