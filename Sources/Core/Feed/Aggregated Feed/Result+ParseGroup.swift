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

public typealias GroupCompletion<T: ActivityProtocol, G: Group<T>> = (_ result: Result<Response<G>, ClientError>) -> Void

// MARK: - Result Group Parsing

extension Result where Value == Moya.Response, Error == ClientError {
    func parseGroup<T: ActivityProtocol, G: Group<T>>(_ callbackQueue: DispatchQueue,
                                                      _ completion: @escaping GroupCompletion<T, G>) {
        parse(block: {
            let moyaResponse = try get()
            let response = try JSONDecoder.stream.decode(Response<G>.self, from: moyaResponse.data)
            callbackQueue.async { completion(.success(response)) }
        }, catch: { error in
            callbackQueue.async { completion(.failure(error)) }
        })
    }
}
