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
    
    private(set) var clientId: String?
    var connectionType: String?
    var version: String?
    var minimumVersion: String?
    var supportedConnectionTypes: [String]?
    public let id: String
    public let channel: String
    public var subscription: String?
    public var ext: [String: String]?
    public var data: String?
    public var successful: Bool?
    public var advice: Advice?
    public var error: String?
    
    init(_ bayeuxChannel: BayeuxChannel, clientId: String?) {
        Message.counter += 1
        id = String(Message.counter, radix: 16)
        self.clientId = clientId
        channel = bayeuxChannel.channel
        
        switch bayeuxChannel {
        case .handshake:
            version = "1.0"
            minimumVersion = "1.0"
            supportedConnectionTypes = ["websocket"]
        case .connect:
            connectionType = "websocket"
        case .subscribe(let channel), .unsubscribe(let channel):
            self.subscription = channel.name
            self.ext = channel.ext
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
    case handshake
    case connect
    case subscribe(_ channel: Channel)
    case unsubscribe(_ channel: Channel)
    
    var channel: String {
        switch self {
        case .handshake:
            return "/meta/handshake"
        case .connect:
            return "/meta/connect"
        case .subscribe:
            return "/meta/subscribe"
        case .unsubscribe:
            return "/meta/unsubscribe"
        }
    }
    
    init?(_ message: Message) {
        switch message.channel {
        case BayeuxChannel.handshake.channel:
            self = .handshake
        case BayeuxChannel.connect.channel:
            self = .connect
        default:
            return nil
        }
    }
}
