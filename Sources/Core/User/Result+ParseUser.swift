//
//  Result+ParseUser.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 17/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

extension Result where Value == Response, Error == ClientError {
    
    /// Parse the result with a given user completion block.
    func parseUser<T: UserProtocol>(_ completion: @escaping UserCompletion<T>) {
        do {
            let response = try dematerialize()
            let reaction = try JSONDecoder.stream.decode(T.self, from: response.data)
            completion(.success(reaction))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error.localizedDescription)))
        }
    }
}
