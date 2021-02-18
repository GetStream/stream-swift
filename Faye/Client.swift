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
    public static var logsEnabled = false
    
    private static let maxAttemptsToReconnect = 5
    
    private let webSocket: WebSocket
    private var weakChannels = [WeakChannel]()
    private var attemptsToReconnect: Int = 0
    private var clientId: String?
    private var advice: Advice?
    
    private var isWebSocketConnected = false
    
    private lazy var handshakeTimer = RepeatingTimer(timeInterval: .seconds(30), queue: webSocket.callbackQueue) { [weak self] in
        self?.ping()
    }
    
    public var isConnected: Bool {
        return clientId != nil && isWebSocketConnected
    }
    
    /// A configuration to initialize the shared Client.
    public static var config = Config(url: URL(fileURLWithPath: "/"))
    
    /// A shared client.
    /// - Note: Setup `Client.config` before using a shared client.
    public static let shared = Client(url: Client.config.url, headers: Client.config.headers)
    
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
        var request = urlRequest
        request.setValue("faye", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        webSocket = WebSocket(request: request)
        webSocket.callbackQueue = callbackQueue
        webSocket.delegate = self
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - Config

extension Client {
    public struct Config {
        let url: URL
        let headers: [String: String]?
        
        public init(url: URL, headers: [String: String]? = nil) {
            self.url = url
            self.headers = headers
        }
    }
}

// MARK: - Public API

extension Client {
    public func connect() {
        guard !isConnected else {
            return
        }
        
        log("Connecting WS...")
        self.webSocket.connect()
    }
    
    public func disconnect() {
        log()
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
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isWebSocketConnected = true
            do {
                try webSocketWrite(.handshake)
                attemptsToReconnect = 0
                handshakeTimer.resume()
            } catch {
                log("❌ WS Connect error:", error)
                applyAdvice()
            }
        case .disconnected(let reason, let code):
            isWebSocketConnected = false
            log()
            handshakeTimer.suspend()
            clientId = nil
            
            log("❌ WS Disconnect: \(reason), \(code)")
            
            applyAdvice()
        case .text(let string):
            guard let data = string.data(using: .utf8) else {
                log("❌", "Bad data encoding")
                return
            }
            
            log("<---", string)
            websocketDidReceiveData(socket: webSocket, data: data)
        case .binary(let data):
            websocketDidReceiveData(socket: webSocket, data: data)
        case .ping(_):
            break
        case .pong(let data):
            log("<--- 🏓", data)
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isWebSocketConnected = false
            log("❌ WS Disconnect: CANCELLED")
        case .error(let error):
            isWebSocketConnected = false
            log("❌ WS Disconnect with error: \(error)")
            //handleError(error)
        }
    }
}

// MARK: - Sending

extension Client {
    private func webSocketWrite(_ bayeuxChannel: BayeuxChannel,
                                _ channel: Channel? = nil,
                                completion: ClientWriteDataCompletion? = nil) throws {
        guard isWebSocketConnected else {
            throw Error.notConnected
        }
        
        guard clientId != nil || bayeuxChannel == BayeuxChannel.handshake else {
            throw Error.clientIdIsEmpty
        }
        
        let message = Message(bayeuxChannel, channel, clientId: self.clientId)
        let data = try JSONEncoder().encode([message])
        webSocket.write(data: data, completion: completion)
        log("--->", message.channel, message.clientId ?? "", message.ext ?? [:])
    }
}

// MARK: - Receiving

extension Client {
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
            log("❌", error)
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
        log("<---", message.channel)
        
        weakChannels.forEach { weakChannel in
            if let channel = weakChannel.channel, channel.name.match(with: message.channel) {
                channel.subscription(jsonData)
            }
        }
    }
    
    private func dispatchHandshake(with message: Message) {
        clientId = message.clientId
        advice = message.advice
        
        for weakChannel in weakChannels {
            if let channel = weakChannel.channel {
                do {
                    try subscribe(to: channel)
                } catch {
                    log("❌ subscribe to channel", channel, error)
                    break
                }
            }
        }
    }
}

// MARK: - Ping/Pong

extension Client {
    public func ping() {
        log("🏓 --->")
        webSocket.write(ping: Data())
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
        
        log("<-->", advice)
        
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
    
    private func retryReconnect(after timeInterval: DispatchTimeInterval = .seconds(2)) {
        guard attemptsToReconnect < Client.maxAttemptsToReconnect else {
            attemptsToReconnect = 0
            return
        }
        
        log()
        webSocket.callbackQueue.asyncAfter(deadline: .now() + timeInterval) { [weak self] in self?.connect() }
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

fileprivate func log(_ title: String = "",
                     _ item1: Any? = nil,
                     _ item2: Any? = nil,
                     _ item3: Any? = nil,
                     function: String = #function) {
    if Client.logsEnabled {
        print("🕸", title, Date(), function, item1 ?? "", item2 ?? "", item3 ?? "")
    }
}
