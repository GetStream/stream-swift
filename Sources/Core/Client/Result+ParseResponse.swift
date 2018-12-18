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

typealias CompletionObject<T> = (_ result: Result<T, ClientError>) -> Void
typealias CompletionObjects<T> = (_ result: Result<[T], ClientError>) -> Void

extension Result where Value == Response, Error == ClientError {
    
    func parseStatusCode(_ completion: @escaping StatusCodeCompletion) {
        do {
            let response = try result.dematerialize()
            completion(.success(response.statusCode))
        } catch {
            if let clientError = error as? ClientError {
                completion(.failure(clientError))
            }
        }
    }
    
    /// Parse a `Decodable` object.
    func parse<T: Decodable>(_ completion: @escaping CompletionObject<T>) {
        do {
            let response = try dematerialize()
            let object = try JSONDecoder.stream.decode(T.self, from: response.data)
            completion(.success(object))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error.localizedDescription, error)))
        }
    }
    
    /// Parse `Decodable` objects with `ResultsContainer`.
    func parse<T: Decodable>(_ completion: @escaping CompletionObjects<T>) {
        do {
            let response = try dematerialize()
            let container = try JSONDecoder.stream.decode(ResultsContainer<T>.self, from: response.data)
            completion(.success(container.results))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error.localizedDescription, error)))
        }
    }
}
