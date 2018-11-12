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
    static let clientHeaderField = "X-Stream-Client"
    
    let token: Token
}

extension AuthorizationMoyaPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue("jwt", forHTTPHeaderField: AuthorizationMoyaPlugin.authTypeHeaderField)
        request.addValue(token, forHTTPHeaderField: AuthorizationMoyaPlugin.authHeaderField)
        request.addValue("stream-swift-client-\(Client.version)", forHTTPHeaderField: AuthorizationMoyaPlugin.clientHeaderField)
        
        return request
    }
}
