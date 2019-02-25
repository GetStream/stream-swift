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
public typealias ClientWriteDataCompletion = () -> Void

public final class Client {
    private static let maxAttemptsToReconnect = 5
    
    private let webSocket: WebSocket
    private var weakChannels = [WeakChannel]()
    private var attemptsToReconnect: Int = 0
    private var clientId: String?
    private var advice: Advice?
    
    private lazy var handshakeTimer = RepeatingTimer(timeInterval: .seconds(30), queue: webSocket.callbackQueue) { [weak self] in
        try? self?.webSocketWrite(.handshake)
    }
    
    public var isConnected: Bool {
        return clientId != nil && webSocket.isConnected
    }
    
    /// Create a Faye client with a given `URL`.
    ///
    /// - Parameters:
    ///     - url: an `URL` of your websocket server.
    ///     - headers: custom headers.
    public convenience init(url: URL, headers: [String: String]? = nil) {
        var urlRequest = URLRequest(url: url)
        
        if let headers = headers {
            headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        self.init(urlRequest: urlRequest)
    }
    
    /// Create a Faye client with a given `URLRequest`.
    ///
    /// - Parameters:
    ///     - urlRequest: an `URLRequest` with `URL`, custom headers and a timeout parameter.
    ///     - callbackQueue: a DispatchQueue for requests.
    public init(urlRequest: URLRequest,
                callbackQueue: DispatchQueue = DispatchQueue(label: "io.getstream.Faye", qos: .userInitiated)) {
        webSocket = WebSocket(request: urlRequest, protocols: ["faye"])
        webSocket.callbackQueue = callbackQueue
        webSocket.delegate = self
        webSocket.pongDelegate = self
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - Public API

extension Client {
    public func connect() {
        guard !isConnected else {
            return
        }
        
        self.webSocket.connect()
    }
    
    public func disconnect() {
        print("🕸", Date(), #function)
        webSocket.disconnect()
        clientId = nil
        advice = nil
    }
}

// MARK: - Channel

extension Client {
    
    public func subscribe(to channel: Channel) throws {
        if !weakChannels.contains(where: { $0.channel == channel }) {
            weakChannels.append(WeakChannel(channel))
        }
        
        guard isConnected else {
            throw Error.notConnected
        }
        
        try webSocketWrite(.subscribe, channel)
    }
    
    func unsubscribe(channel: Channel) throws {
        guard isConnected else {
            return
        }
        
        try webSocketWrite(.unsubscribe, channel)
    }
    
    func remove(channel: Channel) {
        weakChannels = weakChannels.filter { $0.channel != channel }
        try? unsubscribe(channel: channel)
    }
}

// MARK: - Connection

extension Client: WebSocketDelegate {
    
    public func websocketDidConnect(socket: WebSocketClient) {
        do {
            try webSocketWrite(.handshake)
            attemptsToReconnect = 0
            handshakeTimer.resume()
        } catch {
            print("🕸", Date(), #function, error)
            applyAdvice()
        }
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Swift.Error?) {
        print("🕸", Date(), #function)
        handshakeTimer.suspend()
        clientId = nil
        
        if let error = error {
            print("🕸❌", Date(), error)
        }
        
        applyAdvice()
    }
    
    private func retryReconnect(after timeInterval: DispatchTimeInterval = .seconds(2)) {
        guard attemptsToReconnect < Client.maxAttemptsToReconnect else {
            attemptsToReconnect = 0
            return
        }
        
        print("🕸", Date(), #function)
        webSocket.callbackQueue.asyncAfter(deadline: .now() + timeInterval) { [weak self] in self?.connect() }
    }
}

// MARK: - Sending

extension Client {
    private func webSocketWrite(_ bayeuxChannel: BayeuxChannel,
                                _ channel: Channel? = nil,
                                completion: ClientWriteDataCompletion? = nil) throws {
        guard webSocket.isConnected else {
            throw Error.notConnected
        }
        
        guard clientId != nil || bayeuxChannel == BayeuxChannel.handshake else {
            throw Error.clientIdIsEmpty
        }
        
        let message = Message(bayeuxChannel, channel, clientId: self.clientId)
        let data = try JSONEncoder().encode([message])
        webSocket.write(data: data, completion: completion)
        print("🕸 --->", Date(), message.channel, message.clientId ?? "", message.ext ?? [:])
    }
}

// MARK: - Receiving

extension Client {
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            print("🕸❌", Date(), #function, "Bad data encoding")
            return
        }
        
        print("🕸 <---", Date(), text)
        websocketDidReceiveData(socket: socket, data: data)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [JSON] else {
                return
            }
            
            let messages = try JSONDecoder().decode([Message].self, from: data)
            
            messages.forEach { message in
                if !dispatchBayeuxChannel(with: message) {
                    json.forEach {
                        if let subscriptionJSON = $0["data"] as? JSON,
                            let jsonData = try? JSONSerialization.data(withJSONObject: subscriptionJSON) {
                            dispatchData(with: message, in: jsonData)
                        }
                    }
                }
            }
        } catch {
            print("🕸❌", Date(), #function, error)
        }
    }
    
    private func dispatchBayeuxChannel(with message: Message) -> Bool {
        guard let bayeuxChannel = BayeuxChannel(rawValue: message.channel) else {
            return false
        }
        
        if case .handshake = bayeuxChannel {
            dispatchHandshake(with: message)
        }
        
        return true
    }
    
    private func dispatchData(with message: Message, in jsonData: Data) {
        print("🕸 <---", Date(), message.channel)
        
        weakChannels.forEach { weakChannel in
            if let channel = weakChannel.channel, channel.name.match(with: message.channel) {
                channel.subscription(jsonData)
            }
        }
    }
    
    private func dispatchHandshake(with message: Message) {
        let subscribeToChannels = clientId == nil
        clientId = message.clientId
        advice = message.advice
        
        guard subscribeToChannels else {
            return
        }
        
        for weakChannel in weakChannels {
            if let channel = weakChannel.channel {
                do {
                    try subscribe(to: channel)
                } catch {
                    print("🕸❌ subscribe to channel", Date(), #function, channel, error)
                    break
                }
            }
        }
    }
}

// MARK: - Ping/Pong

extension Client: WebSocketPongDelegate {
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("🕸 <--- pong", Date(), data ?? Data())
    }
}

// MARK: - Advice

extension Client {
    private func applyAdvice() {
        clientId = nil
        
        guard let advice = advice else {
            retryReconnect()
            return
        }
        
        print("🕸 <-->", Date(), #function, advice)
        
        switch advice.reconnect {
        case .none:
            return
        case .handshake:
            try? webSocketWrite(.handshake)
        case .retry:
            retryReconnect()
        }
        
        self.advice = nil
    }
}

// MARK: - Error

extension Client {
    public enum Error: String, Swift.Error {
        case notConnected
        case clientIdIsEmpty
    }
}

// MARK: - Helpers

private final class WeakChannel {
    weak var channel: Channel?
    
    init(_ channel: Channel) {
        self.channel = channel
    }
}
