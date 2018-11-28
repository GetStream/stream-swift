//
//  Message.swift
//  Faye
//
//  Created by Alexey Bukhtin on 28/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct Message: Codable {
    static var counter = 0
    
    let clientId: String
    public let id: String
    public let channel: String
    var connectionType: String?
    public var subscription: String?
    public var ext: [String: String]?
    public var data: String?
    public var successful: Bool?
    public var advice: Advice?
    public var error: String?
    
    init(_ bayeuxChannel: BayeuxChannel, clientId: String) {
        Message.counter += 1
        id = String(Message.counter, radix: 16)
        self.clientId = clientId
        channel = "/".appending(bayeuxChannel.channel.slashTrimmed())
        
        switch bayeuxChannel {
        case .connect:
            connectionType = "websocket"
        case .subscribe(let subscription), .unsubscribe(let subscription):
            self.subscription = subscription
        }
    }
}

extension Message {
    public struct Advice: Codable {
        let reconnect: String
        let interval: Int
        let timeout: Int
    }
}

enum BayeuxChannel {
    case connect
    case subscribe(_ subscription: String)
    case unsubscribe(_ subscription: String)
    // case publish(_ data: String)
    
    var channel: String {
        switch self {
        case .connect:
            return "connect"
        case .subscribe:
            return "subscribe"
        case .unsubscribe:
            return "unsubscribe"
        }
    }
}
