//
//  ClientError.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 09/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public enum ClientError: Error {
    case unknown
    case unknownError(_ error: Error)
    case jsonInvalid
    case jsonDecode(_ error: Error, data: Data)
    case jsonEncode(_ error: Error)
    case network(_ description: String)
    case server(_ info: Info)
    
    public var localizedDescription: String {
        switch self {
        case .unknown:
            return "Unexpected behaviour"
        case .unknownError(let error):
            return "Unexpected behaviour with error: \(error)"
        case .jsonInvalid:
            return "A server response is not a JSON"
        case let .jsonDecode(error, data):
            return "JSON decoding error: \(error). Data: \(data.count) bytes"
        case .jsonEncode(let error):
            return "JSON encoding error: \(error)"
        case .network(let description):
            return "Moya error: \(description)"
        case .server(let info):
            return info.description
        }
    }
    
    static func warning(for json: Any, missedParameter parameter: String, from: String = #function) {
        print("⚠️", from, "JSON does not have a parameter \"\(parameter)\" in:", json)
    }
}

// MARK: - Client Error Info

extension ClientError {
    public struct Info: CustomStringConvertible {
        let info: String
        let code: Int
        let statusCode: Int
        let exception: String
        let json: JSON
        
        init(json: JSON) {
            guard let detail = json["detail"] as? String,
                let code = json["code"] as? Int,
                let statusCode = json["status_code"] as? Int,
                let exception = json["exception"] as? String else {
                    info = ""
                    self.code = 0
                    self.statusCode = 0
                    self.exception = ""
                    self.json = json
                    return
            }
            
            info = detail
            self.code = code
            self.statusCode = statusCode
            self.exception = exception
            self.json = [:]
        }
        
        public var description: String {
            return exception.isEmpty ? "JSON response \(json)" : "\(exception)[\(code)] Status Code: \(statusCode), \(info)"
        }
    }
}
