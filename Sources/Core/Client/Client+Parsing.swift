//
//  Client+Parsing.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 16/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

// MARK: - Parsing

extension Client {
    
    static func parseResultsResponse<T: Decodable>(_ result: ClientCompletionResult,
                                            inContainer: Bool = false,
                                            completion: @escaping Completion<T>) {
        if case .success(let response) = result {
            do {
                if inContainer {
                    let container = try JSONDecoder.stream.decode(ResultsContainer<T>.self, from: response.data)
                    completion(.success(container.results))
                } else {
                    let object = try JSONDecoder.stream.decode(T.self, from: response.data)
                    completion(.success([object]))
                }
            } catch {
                completion(.failure(.jsonDecode(error, data: response.data)))
            }
        } else if case .failure(let error) = result {
            completion(.failure(error))
        }
    }
    
    static func parseRemovedResponse(_ result: ClientCompletionResult, completion: @escaping RemovedCompletion) {
        if case .success(let response) = result {
            do {
                let json = try response.mapJSON()
                
                if let json = json as? [String: Any], let removedId = json["removed"] as? String {
                    completion(.success(removedId))
                } else {
                    ClientError.warning(for: json, missedParameter: "removed")
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(ClientError.jsonEncode(error)))
            }
        } else if case .failure(let error) = result {
            completion(.failure(error))
        }
    }
    
    static func parseStatusCodeResponse(_ result: ClientCompletionResult, completion: @escaping StatusCodeCompletion) {
        do {
            let response = try result.dematerialize()
            completion(.success(response.statusCode))
            
        } catch let error as ClientError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknownError(error)))
        }
    }
}

// MARK: - Results Container

fileprivate struct ResultsContainer<T: Decodable>: Decodable {
    private enum CodingKeys: String, Swift.CodingKey {
        case results
        case next
        case duration
    }
    
    let results: [T]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decode([T].self, forKey: .results)
    }
}
