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
    case jsonInvalid
    case jsonDecode(_ error: Error)
    case jsonEncode(_ error: Error)
    case network(_ description: String)
    case server(_ info: Info)
    
    init(json: JSON) {
        guard let detail = json["detail"] as? String,
            let code = json["code"] as? Int,
            let statusCode = json["status_code"] as? Int,
            let exception = json["exception"] as? String else {
                self = .unknown
                return
        }
        
        self = .server(Info(info: detail, code: code, statusCode: statusCode, exception: exception))
    }
    
    public var localizedDescription: String {
        switch self {
        case .unknown:
            return "Unexpected behaviour"
        case .jsonInvalid:
            return "A server response is not a JSON"
        case .jsonDecode(let error):
            return "JSON decoding error: \(error)"
        case .jsonEncode(let error):
            return "JSON encoding error: \(error)"
        case .network(let description):
            return "Moya error: \(description)"
        case .server(let info):
            return info.description
        }
    }
}

extension ClientError {
    public struct Info: CustomStringConvertible {
        let info: String
        let code: Int
        let statusCode: Int
        let exception: String
        
        public var description: String {
            return "\(exception)[\(code)] Status Code: \(statusCode), \(info)"
        }
    }
}
