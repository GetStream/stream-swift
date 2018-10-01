//
//  StreamAPIClient.swift
//  StreamAPIClient
//
//  Created by tommaso barbugli on 9/29/18.
//  Copyright © 2018 Stream.io. All rights reserved.
//

import Foundation

struct ApiConnectionOptions {}

func CreateUserSession(apiKey : String, userToken : String) throws -> Client {
    let client = try! Client(apiKey: apiKey, authToken: userToken)
    return client
}
