//
//  AuthorizationMoyaPlugin.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 08/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

struct AuthorizationMoyaPlugin {
    static let authTypeHeaderField = "Stream-Auth-Type"
    static let authHeaderField = "Authorization"
    
    /// The API key, it can be safely shared with untrusted entities.
    let apiKey: String
    
    /// A reference to the application id in Stream. This is only used for realtime notifications.
    let appId: String
    
    /// The API secret, it is used to generate the feed tokens.
    let secretKey: String?
    
    var token: String {
        return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6ImZlZWQiLCJhY3Rpb24iOiJyZWFkIiwiZmVlZF9pZCI6InRpbWVsaW5lX2FnZ3JlZ2F0ZWQxMjMifQ.K2cJAMhj1B3RQng-6LjyyMcIEnl3NRAi60etSwvy6zA"
    }
}

extension AuthorizationMoyaPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutableRequest = request
        
        mutableRequest.addValue("jwt", forHTTPHeaderField: AuthorizationMoyaPlugin.authTypeHeaderField)
        mutableRequest.addValue(token, forHTTPHeaderField: AuthorizationMoyaPlugin.authHeaderField)
        
        return mutableRequest
    }
}
