//
//  ClientError.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 09/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public enum ClientError: LocalizedError, CustomStringConvertible {
    case unexpectedError(_ error: Error?)
    case unexpectedResponse(_ description: String)
    case unknownError(_ localizedDescription: String, _ error: Error?)
    case parameterInvalid(_ name: AnyKeyPath)
    case jsonInvalid(_ description: String?)
    case jsonDecode(_ localizedDescription: String, _ error: Error?, _ data: Data)
    case jsonEncode(_ localizedDescription: String, _ error: Error?)
    case network(_ description: String, _ error: Error?)
    case server(_ info: Info)
    
    public var description: String {
        switch self {
        case .unexpectedError(let error):
            return "Unexpected behaviour: \(error?.localizedDescription ?? "<NoError>")"
        case .unexpectedResponse:
            return "Unexpected response"
        case .unknownError(let localizedDescription, _):
            return "Unexpected behaviour with error: \(localizedDescription)"
        case .parameterInvalid(let name):
            return "Parameter is not valid: \(name)"
        case .jsonInvalid(let description):
            return "A server response is not a JSON: \(description ?? "<no data>")"
        case let .jsonDecode(localizedDescription, _, data):
            return "JSON decoding error: \(localizedDescription). Data: \(data.count) bytes"
        case .jsonEncode(let localizedDescription, _):
            return "JSON encoding error: \(localizedDescription)"
        case .network(let description, _):
            return "Moya error: \(description)"
        case .server(let info):
            return info.description
        }
    }
    
    public var localizedDescription: String {
        return description
    }
    
    public var errorDescription: String? {
        return description
    }
    
    static func warning(for json: Any, missedParameter parameter: String, from: String = #function) {
        print("⚠️", from, "JSON does not have a parameter \"\(parameter)\" in:", json)
    }
}

// MARK: - Client Error Info

extension ClientError {
    /// A client error details.
    public struct Info: CustomStringConvertible {
        public let info: String
        public let code: Int
        public let statusCode: Int
        public let exception: String
        public let json: JSON
        
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
