//
//  Channel.swift
//  Faye
//
//  Created by Alexey Bukhtin on 26/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias ChannelSubscription = (_ data: Data) -> Void

public final class Channel: Equatable {
    
    private weak var client: Client?
    let subscription: ChannelSubscription
    public let name: ChannelName
    public var ext: [String: String]?
    
    public init(_ name: ChannelName, client: Client, subscription: @escaping ChannelSubscription) {
        self.name = "/".appending(name.slashTrimmed())
        self.client = client
        self.subscription = subscription
    }
    
    public func unsubscribe() {
        client?.remove(channel: self)
    }
    
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.name == rhs.name
    }
}
