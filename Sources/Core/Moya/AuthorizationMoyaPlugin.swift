//
//  AuthorizationMoyaPlugin.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 08/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

final class AuthorizationMoyaPlugin: PluginType {
    private let serialQueue = DispatchQueue(label: "com.getstream.io.AuthorizationMoyaPlugin")
    private var token: Token

    init(_ token: Token = "") {
        self.token = token
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        let token = serialQueue.sync { self.token }

        if token.isEmpty {
            return request
        }

        var request = request
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")

        return request
    }

    func updateToken(_ token: Token) {
        serialQueue.async {
            self.token = token
        }
    }
}
