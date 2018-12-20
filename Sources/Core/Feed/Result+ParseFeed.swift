//
//  Result+ParseFeed.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

public typealias RemovedCompletion = (_ result: Result<String, ClientError>) -> Void

extension Result where Value == Response, Error == ClientError {
    func parseRemoved(_ completion: @escaping RemovedCompletion) {
        if case .success(let response) = self {
            do {
                let json = try response.mapJSON()
                
                if let json = json as? [String: Any], let removedId = json["removed"] as? String {
                    completion(.success(removedId))
                } else {
                    ClientError.warning(for: json, missedParameter: "removed")
                    completion(.failure(.unexpectedResponse("`removed` parameter not found")))
                }
            } catch {
                completion(.failure(ClientError.jsonDecode(error.localizedDescription, error, response.data)))
            }
        } else if case .failure(let error) = self {
            completion(.failure(error))
        }
    }
}
