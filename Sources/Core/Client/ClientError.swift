//
//  ClientError.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 09/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public enum ClientError: Error {
    case unexpectedError
    case unexpectedResponse(_ description: String)
    case unknownError(_ localizedDescription: String)
    case jsonInvalid
    case jsonDecode(_ localizedDescription: String, data: Data)
    case jsonEncode(_ localizedDescription: String)
    case network(_ description: String)
    case server(_ info: Info)
    
    public var localizedDescription: String {
        switch self {
        case .unexpectedError:
            return "Unexpected behaviour"
        case .unexpectedResponse:
            return "Unexpected response"
        case .unknownError(let localizedDescription):
            return "Unexpected behaviour with error: \(localizedDescription)"
        case .jsonInvalid:
            return "A server response is not a JSON"
        case let .jsonDecode(localizedDescription, data):
            return "JSON decoding error: \(localizedDescription). Data: \(data.count) bytes"
        case .jsonEncode(let localizedDescription):
            return "JSON encoding error: \(localizedDescription)"
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
