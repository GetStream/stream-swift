//
//  Channel.swift
//  Faye
//
//  Created by Alexey Bukhtin on 26/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias ChannelSubscription = (_ channel: Channel, _ message: String) -> Void

public final class Channel {
    public let name: ChannelName
    let subscription: ChannelSubscription
    private weak var client: Client?
    
    public init(_ name: ChannelName, client: Client, subscription: @escaping ChannelSubscription) {
        self.name = name.slashTrimmed()
        self.client = client
        self.subscription = subscription
        client.add(channel: self)
    }
    
    deinit {
        client?.remove(channel: self)
    }
}

extension Channel {
    public enum Error: Swift.Error {
        case clientNotFound
    }
}

// MARK: - Publishing

extension Channel {
    public func publish(_ object: Encodable,
                        encoder: JSONEncoder = JSONEncoder(),
                        to segment: ChannelName? = nil,
                        completion: ClientWriteDataCompletion? = nil) throws {
        guard let client = client else {
            throw Error.clientNotFound
        }
        
        try client.publish(in: try name.wildcard(with: segment), object: object, encoder: encoder, completion: completion)
    }
}
