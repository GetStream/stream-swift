//
//  GetStream.swift
//  Stream.io Inc
//
//  Created by Alexey Bukhtin on 06/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Require

public final class Client {
    
    open static var location: Client.Location = .usEast
    
    public static var baseURL: URL {
        return URL(string: "https://\(location.rawValue)api.stream-io-api.com/api/v1.0/").require()
    }
    
    private let moyaProvider = MoyaProvider<MultiTarget>()
    
    /// The API key, it can be safely shared with untrusted entities.
    private let apiKey: String
    
    /// A reference to the application id in Stream. This is only used for realtime notifications.
    private let appId: String
    
    /// The API secret, it is used to generate the feed tokens.
    private let secretKey: String?
    
    init(apiKey: String, appId: String, secretKey: String? = nil, location: Client.Location = .usEast) {
        self.apiKey = apiKey
        self.appId = appId
        self.secretKey = secretKey
        Client.location = location
    }
}

extension Client {
    public enum Location: String {
        case usEast = "us-east-"
        case europeWest = "eu-west-"
        case singapore = "singapore-"
    }
}
