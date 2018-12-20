//
//  Result+ParseGroup.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

extension Result where Value == Response, Error == ClientError {
    func parseGroup<T: Decodable>(_ completion: @escaping GroupCompletion<T>) {
        if case .success(let response) = self {
            do {
                let container = try JSONDecoder.stream.decode(ResultsContainer<Group<T>>.self, from: response.data)
                completion(.success(container.results))
            } catch let error as ClientError {
                completion(.failure(error))
            } catch {
                completion(.failure(.jsonDecode(error.localizedDescription, error, response.data)))
            }
        } else if case .failure(let error) = self {
            completion(.failure(error))
        }
    }
}
