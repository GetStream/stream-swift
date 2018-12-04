//
//  ClientAuthFayePlugin.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 30/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Faye

struct ClientAuthFayePlugin: ClientPluginProtocol {
    
    let client: Client
    
    func outgoing(message: Message) -> Message {
        guard message.channel != "/meta/connect" else {
            return message
        }
        
        var message = message
        
        message.ext = ["api_key": client.apiKey,
                       "signature": client.token,
//                       "user_id": client.userId
        ]
        
        return message
    }
}

