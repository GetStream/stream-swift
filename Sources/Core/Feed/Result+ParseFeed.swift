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

extension Result where Value == Response, Error == ClientError {
    
    func parseFollowers(completion: @escaping FollowersCompletion) {
        do {
            let response = try dematerialize()
            let container = try JSONDecoder.stream.decode(ResultsContainer<Follower>.self, from: response.data)
            completion(.success(container.results))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error.localizedDescription)))
        }
    }
    
    func parseRemoved(completion: @escaping RemovedCompletion) {
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
                completion(.failure(ClientError.jsonDecode(error.localizedDescription, data: response.data)))
            }
        } else if case .failure(let error) = self {
            completion(.failure(error))
        }
    }
}
