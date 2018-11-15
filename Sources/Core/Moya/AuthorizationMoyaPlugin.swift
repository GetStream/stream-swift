//
//  AuthorizationMoyaPlugin.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 08/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

struct AuthorizationMoyaPlugin: PluginType {
    let token: Token
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("stream-swift-client-\(Client.version)", forHTTPHeaderField: "X-Stream-Client")
        
        return request
    }
}
