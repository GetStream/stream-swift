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

typealias CompletionObject<T: Decodable> = (_ result: Result<T, ClientError>) -> Void
typealias CompletionObjects<T: Decodable> = (_ result: Result<Response<T>, ClientError>) -> Void

// MARK: - Result Parsing

extension Result where Value == Moya.Response, Error == ClientError {
    
    /// Parse a response and return the status code.
    func parseStatusCode(_ completion: @escaping StatusCodeCompletion) {
        do {
            let response = try result.get()
            completion(.success(response.statusCode))
        } catch {
            if let clientError = error as? ClientError {
                completion(.failure(clientError))
            }
        }
    }
    
    /// Parse a `Decodable` object.
    func parse<T: Decodable>(_ completion: @escaping CompletionObject<T>) {
        parse(block: {
            let response = try get()
            let object = try JSONDecoder.stream.decode(T.self, from: response.data)
            completion(.success(object))
        }, catch: {
            completion(.failure($0))
        })
    }
    
    /// Parse `Decodable` objects with `ResultsContainer`.
    func parse<T: Decodable>(_ completion: @escaping CompletionObjects<T>) {
        parse(block: {
            let moyaResponse = try get()
            var response = try JSONDecoder.stream.decode(Response<T>.self, from: moyaResponse.data)
            
            if let next = response.next, case .none = next {
                response.next = nil
            }
            
            completion(.success(response))
        }, catch: {
            completion(.failure($0))
        })
    }
    
    /// Try to parse a block or catch and return an error.
    func parse(block: () throws -> Void, catch errorBlock: @escaping (_ error: ClientError) -> Void) {
        do {
            try block()
        } catch let error as ClientError {
            errorBlock(error)
        } catch let error as DecodingError {
            if case .success(let response) = self {
                errorBlock(ClientError.jsonDecode(error.localizedDescription, error, response.data))
            } else {
                errorBlock(ClientError.jsonDecode(error.localizedDescription, error, Data()))
            }
        } catch {
            errorBlock(ClientError.unknownError(error.localizedDescription, error))
        }
    }
}
