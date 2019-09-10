//
//  Result+ParseFeed.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

/// An activity removed completion block.
public typealias RemovedCompletion = (_ result: Result<String, ClientError>) -> Void

// MARK: - Result Removed Parsing

extension Result where Success == Moya.Response, Failure == ClientError {
    func parseRemoved(_ callbackQueue: DispatchQueue, _ completion: @escaping RemovedCompletion) {
        if case .success(let response) = self {
            do {
                let json = try response.mapJSON()
                
                if let json = json as? [String: Any], let removedId = json["removed"] as? String {
                    callbackQueue.async { completion(.success(removedId)) }
                } else {
                    ClientError.warning(for: json, missedParameter: "removed")
                    callbackQueue.async { completion(.failure(.unexpectedResponse("`removed` parameter not found"))) }
                }
            } catch {
                callbackQueue.async { completion(.failure(ClientError.jsonDecode(error.localizedDescription, error, response.data))) }
            }
        } else if case .failure(let error) = self {
            callbackQueue.async { completion(.failure(error)) }
        }
    }
}
