//
//  Result+ParseActivity.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

extension Result where Value == Response, Error == ClientError {
    func parseActivities<T: Decodable>(inContainer: Bool = false, _ completion: @escaping ActivitiesCompletion<T>) {
        if case .success(let response) = self {
            do {
                if inContainer {
                    let container = try JSONDecoder.stream.decode(ResultsContainer<T>.self, from: response.data)
                    completion(.success(container.results))
                } else {
                    let object = try JSONDecoder.stream.decode(T.self, from: response.data)
                    completion(.success([object]))
                }
            } catch let error as ClientError {
                completion(.failure(error))
            } catch {
                completion(.failure(.jsonDecode(error.localizedDescription, data: response.data)))
            }
        } else if case .failure(let error) = self {
            completion(.failure(error))
        }
    }
}
