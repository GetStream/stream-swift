//
//  Client.swift
//  Faye
//
//  Created by Alexey Bukhtin on 26/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Starscream

public typealias JSON = [String: Any]
public typealias ClientConnected = (_ isConnected: Bool, _ error: Error?) -> Void
public typealias ClientWriteDataCompletion = () -> Void

public protocol PluginProtocol {
    func outgoing(message: Message) -> Message
}

public final class Client {
    private let webSocket: WebSocket
    private let plugins: [PluginProtocol]
    private var clientUUID: UUID = UUID()
    private var connectedCallbacks = [ClientConnected]()
    private var weakChannels = [WeakChannel]()
    
    private var clientId: String {
        return clientUUID.uuidString.lowercased()
    }

    public var isConnected: Bool {
        return webSocket.isConnected
    }
    
    private var channels: [Channel] {
        return weakChannels.compactMap { $0.channel }
    }
    
    /// Create a Faye client with a given `URL`.
    ///
    /// - Parameters:
    ///     - url: an `URL` of your websocket server.
    ///     - headers: custom headers.
    ///     - protocols: websocket protocols for the header: `Sec-WebSocket-Protocol`, e.g. `chat`.
    ///     - plugins: a list of `PluginProtocol` plugins to manager incoming/outgoing messages.
    public convenience init(url: URL,
                            headers: [String: String]? = nil,
                            protocols: [String]? = nil,
                            plugins: [PluginProtocol] = []) {
        var urlRequest = URLRequest(url: url)
        
        if let headers = headers {
            headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        self.init(urlRequest: urlRequest, protocols: protocols, plugins: plugins)
    }
    
    /// Create a Faye client with a given `URLRequest`.
    ///
    /// - Parameters:
    ///     - urlRequest: an `URLRequest` with `URL`, custom headers and a timeout parameter.
    ///     - protocols: websocket protocols for the header: `Sec-WebSocket-Protocol`, e.g. `chat`.
    ///     - plugins: a list of `PluginProtocol` plugins to manager incoming/outgoing messages.
    public init(urlRequest: URLRequest, protocols: [String]? = nil, plugins: [PluginProtocol] = []) {
        self.plugins = plugins
        webSocket = WebSocket(request: urlRequest, protocols: protocols)
        webSocket.onConnect = webSocketDidConnect
        webSocket.onDisconnect = webSocketDidDisconnect
        webSocket.onText = webSocketDidReceiveMessage
        webSocket.onData = webSocketDidReceiveData
    }
}

// MARK: - Public API

extension Client {
    public func connect(completion: ClientConnected? = nil) {
        guard isConnected else {
            completion?(true, nil)
            return
        }
        
        webSocket.callbackQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if let completion = completion {
                self.connectedCallbacks.append(completion)
            }
            
            self.webSocket.connect()
        }
    }
    
    public func disconnect() {
        if webSocket.isConnected {
            webSocket.disconnect()
        }
    }
    
    public func channel(_ name: String, subscription: @escaping ChannelSubscription) -> Channel {
        return Channel(name, client: self, subscription: subscription)
    }
}

// MARK: - Channel

extension Client {
    func add(channel: Channel) {
        weakChannels.append(WeakChannel(channel))
        try? subscribe(channel: channel)
    }
    
    func remove(channel: Channel) {
        if let index = weakChannels.firstIndex(where: { $0.channel === channel }) {
            weakChannels.remove(at: index)
        }
        
        unsubscribe(channel: channel)
    }
    
    func subscribe(channel: Channel, completion: ClientWriteDataCompletion? = nil) throws {
        guard isConnected else {
            connect { [weak self] connected, _ in
                if connected {
                    try? self?.subscribe(channel: channel, completion: completion)
                }
            }
            
            return
        }
        
        try send(.subscribe(channel.name), completion: completion)
    }
    
    func unsubscribe(channel: Channel) {
        guard isConnected else {
            return
        }
    }
    
    private func send(_ bayeuxChannel: BayeuxChannel, completion: ClientWriteDataCompletion? = nil) throws {
        var message = Message(bayeuxChannel, clientId: clientId)
        message = applyPlugins(for: message)
        let data = try JSONEncoder().encode(message)
        webSocket.write(data: data, completion: completion)
    }
}

private final class WeakChannel {
    weak var channel: Channel?
    
    init(_ channel: Channel) {
        self.channel = channel
    }
}

// MARK: - Plugins

extension Client {
    private func applyPlugins(for message: Message) -> Message {
        var message = message
        plugins.forEach { message = $0.outgoing(message: message) }
        return message
    }
}

// MARK: - WebSocket requests

extension Client {
    /// TODO: publish
    func publish(in channelName: String, object: Encodable, encoder: JSONEncoder, completion: ClientWriteDataCompletion?) throws {
        completion?()
//        guard isConnected else {
//            connect { [weak self] connected, _ in
//                if connected {
//                    try? self?.publish(in: channelName, json: json, completion: completion)
//                }
//            }
//
//            return
//        }
//
//        let data = encoder.encode(<#T##value: Encodable##Encodable#>)
//        var message = Message(., clientId: <#T##String#>)
//
//        let data = try JSONEncoder().encode(bayeux)
//        webSocket.write(data: data, completion: completion)
    }
}

// MARK: - WebSocket

extension Client {
    private func webSocketDidConnect() {
        notifyConnectedCallbacks(isConnected: true)
        try? send(.connect)
        channels.forEach { [weak self] in try? self?.subscribe(channel: $0) }
    }
    
    private func webSocketDidDisconnect(_ error: Error?) {
        notifyConnectedCallbacks(isConnected: false, error: error)
        clientUUID = UUID()
    }
    
    private func webSocketDidReceiveMessage(text: String) {
//        channels.filter { $0.isRelated(to: channelName) }.forEach { $0.subscription($0, message) }
    }
    
    private func webSocketDidReceiveData(data: Data) {
    }
    
    private func notifyConnectedCallbacks(isConnected: Bool, error: Error? = nil) {
        connectedCallbacks.forEach { $0(isConnected, error) }
        connectedCallbacks = []
    }
}
