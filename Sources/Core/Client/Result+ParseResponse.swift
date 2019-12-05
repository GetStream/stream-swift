//
//  Result+ParseResponse.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

typealias CompletionObject<T: Decodable> = (_ result: Result<T, ClientError>) -> Void
typealias CompletionObjects<T: Decodable> = (_ result: Result<Response<T>, ClientError>) -> Void

// MARK: - Result Parsing

extension Result where Success == Moya.Response, Failure == ClientError {
    
    /// Parse a response and return the status code.
    func parseStatusCode(_ callbackQueue: DispatchQueue, _ completion: @escaping StatusCodeCompletion) {
        do {
            let response = try get()
            callbackQueue.async { completion(.success(response.statusCode)) }
        } catch {
            if let clientError = error as? ClientError {
                callbackQueue.async { completion(.failure(clientError)) }
            }
        }
    }
    
    /// Parse a `Decodable` object.
    func parse<T: Decodable>(_ callbackQueue: DispatchQueue, _ completion: @escaping CompletionObject<T>) {
        parse(block: {
            let response = try get()
            let object = try JSONDecoder.default.decode(T.self, from: response.data)
            callbackQueue.async { completion(.success(object)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
    
    /// Parse `Decodable` objects with `ResultsContainer`.
    func parse<T: Decodable>(_ callbackQueue: DispatchQueue, _ completion: @escaping CompletionObjects<T>) {
        parse(block: {
            let moyaResponse = try get()
            var response = try JSONDecoder.default.decode(Response<T>.self, from: moyaResponse.data)
            
            if let next = response.next, case .none = next {
                response.next = nil
            }
            
            callbackQueue.async { completion(.success(response)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
    
    /// Try to parse a block or catch and return an error.
    func parse(block: () throws -> Void, catch errorBlock: @escaping (_ error: ClientError) -> Void) {
        do {
            try block()
        } catch let error as ClientError {
            errorBlock(error)
        } catch let error as DecodingError {
            if error.errorDescription == "Expected to decode Dictionary<String, Any> but found a string/data instead." {
                print("⚠️ Probably you are trying to get activities with enrichment. Usually, the actor field has wrong value.\n"
                    + "☝️ The enrichments is enabled by default in requests. Try to switch it off with the parameter: `enrich: false`."
                    + "ℹ️ Learn more about it here: https://getstream.io/docs/#enrichment_introduction")
            }
            
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
