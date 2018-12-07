//
//  Message.swift
//  Faye
//
//  Created by Alexey Bukhtin on 28/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct Message: Codable {
    
    var clientId: String?
    var connectionType: String?
    var version: String?
    var minimumVersion: String?
    var supportedConnectionTypes: [String]?
    var advice: Advice?
    var successful: Bool?
    public let channel: ChannelName
    public var id: String?
    public var subscription: String?
    public var ext: [String: String]?
    public var error: String?
    
    init(_ bayeuxChannel: BayeuxChannel, _ channel: Channel?, clientId: String?) {
        id = Message.Counter.value
        self.clientId = clientId
        self.channel = bayeuxChannel.rawValue
        
        switch bayeuxChannel {
        case .handshake:
            version = "1.0"
            minimumVersion = "1.0"
            supportedConnectionTypes = ["websocket"]
        case .connect:
            connectionType = "websocket"
        case .subscribe, .unsubscribe:
            subscription = channel?.name
            ext = channel?.ext
        }
    }
}

// MARK: Counter

extension Message {
    struct Counter {
        private static var id = 0
        
        static var value: String {
            id += 1
            return String(id, radix: 16)
        }
    }
}

// MARK: Advice

struct Advice: Codable {
    let reconnect: Reconnection
    let interval: Int
    let timeout: Int
}

extension Advice {
    enum Reconnection: String, Codable {
        case none
        case handshake
        case retry
    }
}

// MARK: Bayeux Channels

enum BayeuxChannel: ChannelName {
    case handshake = "/meta/handshake"
    case connect = "/meta/connect"
    case subscribe = "/meta/subscribe"
    case unsubscribe = "/meta/unsubscribe"
}
