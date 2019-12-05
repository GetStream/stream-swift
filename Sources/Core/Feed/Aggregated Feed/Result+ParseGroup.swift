//
//  Result+ParseGroup.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

/// An aggregated group completion block.
public typealias GroupCompletion<T: ActivityProtocol, G: Group<T>> = (_ result: Result<Response<G>, ClientError>) -> Void

// MARK: - Result Group Parsing

extension Result where Success == Moya.Response, Failure == ClientError {
    func parseGroup<T: ActivityProtocol, G: Group<T>>(_ callbackQueue: DispatchQueue,
                                                      _ completion: @escaping GroupCompletion<T, G>) {
        parse(block: {
            let moyaResponse = try get()
            let response = try JSONDecoder.default.decode(Response<G>.self, from: moyaResponse.data)
            callbackQueue.async { completion(.success(response)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
}
