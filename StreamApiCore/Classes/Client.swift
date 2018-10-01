//
//  Client.swift
//  StreamAPIClient
//
//  Created by tommaso barbugli on 9/29/18.
//  Copyright © 2018 Stream.io. All rights reserved.
//

import Foundation
import JWTDecode

public class Client {
    let apiKey : String
    let authToken : String
    public let currentUser : String

    public init(apiKey : String, authToken : String) throws {
        self.apiKey = apiKey
        self.authToken = authToken

        // TODO: raise better error here
        let decodedToken = try decode(jwt: authToken)

        // TODO: raise better error here
        currentUser = decodedToken.body["user_id"] as! String
    }

    public func feed(group : String) -> Feed {
        return Feed(group, currentUser)
    }

    public func feed(group : String, userID : String) -> Feed {
        return Feed(group, userID)
    }

    // HTTP client part
    func get() {}
    
    func post() {}
    
    func delete() {}

}
