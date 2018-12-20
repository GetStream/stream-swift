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

public typealias GroupCompletion<T: ActivityProtocol, G: Group<T>> = (_ result: Result<[G], ClientError>) -> Void

extension Result where Value == Response, Error == ClientError {
    func parseGroup<T: ActivityProtocol, G: Group<T>>(_ completion: @escaping GroupCompletion<T, G>) {
        if case .success(let response) = self {
            do {
                let container = try JSONDecoder.stream.decode(ResultsContainer<G>.self, from: response.data)
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
