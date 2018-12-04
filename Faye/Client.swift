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

public protocol ClientPluginProtocol {
    func outgoing(message: Message) -> Message
}

public final class Client {
    private let webSocket: WebSocket
    private let plugins: [ClientPluginProtocol]
    private var connectedCallbacks = [ClientConnected]()
    private var weakChannels = [WeakChannel]()
    private var isConnected: Bool = false
    
    private var clientId: String? {
        didSet {
            isConnected = clientId != nil
        }
    }
    
    private var channels: [Channel] {
        return weakChannels.compactMap { $0.channel }
    }
    
    /// Create a Faye client with a given `URL`.
    ///
    /// - Parameters:
    ///     - url: an `URL` of your websocket server.
    ///     - headers: custom headers.
    ///     - plugins: a list of `PluginProtocol` plugins to manager incoming/outgoing messages.
    public convenience init(url: URL, headers: [String: String]? = nil, plugins: [ClientPluginProtocol] = []) {
        var urlRequest = URLRequest(url: url)
        
        if let headers = headers {
            headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        self.init(urlRequest: urlRequest, plugins: plugins)
    }
    
    /// Create a Faye client with a given `URLRequest`.
    ///
    /// - Parameters:
    ///     - urlRequest: an `URLRequest` with `URL`, custom headers and a timeout parameter.
    ///     - plugins: a list of `PluginProtocol` plugins to manager incoming/outgoing messages.
    public init(urlRequest: URLRequest, plugins: [ClientPluginProtocol] = []) {
        self.plugins = plugins
        webSocket = WebSocket(request: urlRequest, protocols: ["faye"])
        webSocket.onConnect = webSocketDidConnect
        webSocket.onDisconnect = webSocketDidDisconnect
        webSocket.onText = webSocketDidReceiveMessage
        webSocket.onData = webSocketDidReceiveData
        webSocket.onPong = webSocketDidReceivePong
    }
}

// MARK: - Public API

extension Client {
    public func connect(completion: ClientConnected? = nil) {
        guard !isConnected else {
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
            clientId = nil
        }
    }
}

// MARK: - Channel

extension Client {
    public func subscribe(to channel: Channel) throws {
        guard isConnected else {
            throw Error.notConnected
        }
        
        try webSocketWrite(.subscribe(channel)) { [weak self] in
            self?.weakChannels.append(WeakChannel(channel))
        }
    }
    
    func unsubscribe(channel: Channel) throws {
        guard isConnected else {
            return
        }
        
        try webSocketWrite(.unsubscribe(channel))
    }
    
    func remove(channel: Channel) {
        weakChannels = weakChannels.filter { $0.channel != nil }
        try? unsubscribe(channel: channel)
    }
}

// MARK: - Sending/Receiving

extension Client {
    
    private func webSocketWrite(_ bayeuxChannel: BayeuxChannel, completion: ClientWriteDataCompletion? = nil) throws {
        guard webSocket.isConnected else {
            throw Error.notConnected
        }
        
        guard clientId != nil || bayeuxChannel.channel == BayeuxChannel.handshake.channel else {
            throw Error.clientIdIsEmpty
        }
        
        let message = self.applyPlugins(for: Message(bayeuxChannel, clientId: self.clientId))
        let data = try JSONEncoder().encode([message])
        print("🕸 --->", message)
        
        webSocket.callbackQueue.async { [weak self] in
            self?.webSocket.write(data: data, completion: completion)
        }
    }
    
    private func webSocketDidConnect() {
        do {
            try webSocketWrite(.handshake)
        } catch {
            print("🕸", #function, error)
        }
    }
    
    private func webSocketDidDisconnect(_ error: Swift.Error?) {
        clientId = nil
        notifyConnectedCallbacks(isConnected: false, error: error)
    }
    
    private func webSocketDidReceivePong(data: Data?) {
        print("🕸 <--- pong", data)
    }
    
    private func webSocketDidReceiveMessage(text: String) {
        guard let data = text.data(using: .utf8) else {
            print("🕸❌", #function, "Bad data encoding")
            return
        }
        
        print("🕸 <---", text)
        webSocketDidReceiveData(data: data)
    }
    
    private func webSocketDidReceiveData(data: Data) {
        do {
            let decoder = JSONDecoder()
            let messages = try decoder.decode([Message].self, from: data)
            messages.forEach { dispatch($0) }
        } catch {
            print("🕸❌", #function, error)
        }
    }
    
    private func dispatch(_ message: Message) {
        if dispatchBayeuxChannel(message) {
            return
        }
        
        channels.forEach { channel in
            if channel.name.match(with: message.channel) {
                channel.subscription(channel, message)
            }
        }
    }
    
    private func dispatchBayeuxChannel(_ message: Message) -> Bool {
        guard let bayeuxChannel = BayeuxChannel(message) else {
            return false
        }
        
        if case .handshake = bayeuxChannel {
            clientId = message.clientId
            notifyConnectedCallbacks(isConnected: true)
            channels.forEach { try? self.subscribe(to: $0) }
        }
        
        return true
    }
    
    private func notifyConnectedCallbacks(isConnected: Bool, error: Swift.Error? = nil) {
        connectedCallbacks.forEach { $0(isConnected, error) }
        connectedCallbacks = []
    }
}

// MARK: - Error

extension Client {
    public enum Error: String, Swift.Error {
        case notConnected
        case clientIdIsEmpty
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

// MARK: - Helpers

private final class WeakChannel {
    weak var channel: Channel?
    
    init(_ channel: Channel) {
        self.channel = channel
    }
}
