//
//  LoggerPlugin.swift
//  Faye
//
//  Created by Alexey Bukhtin on 27/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct LoggerPlugin: PluginProtocol {
    public func outgoing(message: Message) -> Message {
        print(#function, message.id, message.channel, message.ext ?? [:])
        return message
    }
}
