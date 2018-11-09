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
    case network(_ description: String)
    
    // Server side errors and warnings:
    
    case serverUnknown(_ info: Info)
    case notAllowed(_ info: Info)
    case feedDoesNotExists(_ info: Info)
    
    init(json: JSON) {
        guard let detail = json["detail"] as? String,
            let code = json["code"] as? Int,
            let statusCode = json["status_code"] as? Int,
            let exception = json["exception"] as? String,
            let duration = json["duration"] as? String else {
                self = .unknown
                return
        }
        
        let info = Info(info: detail, code: code, statusCode: statusCode, exception: exception, duration: duration)
        
        switch code {
        case 16:
            self = .feedDoesNotExists(info)
        default:
            self = .serverUnknown(info)
        }
    }
}

extension ClientError {
    public struct Info {
        let info: String
        let code: Int
        let statusCode: Int
        let exception: String
        let duration: String
    }
}
