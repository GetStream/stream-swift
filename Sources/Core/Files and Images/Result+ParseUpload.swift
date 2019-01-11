//
//  Result+ParseUpload.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

public typealias UploadCompletion = (_ result: Result<URL, ClientError>) -> Void

extension Result where Value == Moya.Response, Error == ClientError {
    func parseUpload(_ completion: @escaping UploadCompletion) {
        if case .success(let response) = self {
            do {
                let json = try response.mapJSON()
                
                if let json = json as? JSON, let urlString = json["file"] as? String, let url = URL(string: urlString) {
                    completion(.success(url))
                } else {
                    ClientError.warning(for: json, missedParameter: "file")
                    completion(.failure(.unexpectedResponse("`file` parameter not found")))
                }
                
            } catch {
                if let clientError = error as? ClientError {
                    completion(.failure(clientError))
                }
            }
        } else if case .failure(let error) = self {
            completion(.failure(error))
        }
    }
}
