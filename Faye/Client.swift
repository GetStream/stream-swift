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

public final class Client {
    private let webSocket: WebSocket
    private var connectedCallbacks = [ClientConnected]()
    private var weakChannels = [WeakChannel]()
    private var isConnected: Bool = false
    
    private var clientId: String? {
        didSet {
            isConnected = clientId != nil
        }
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
        webSocket.onConnect = webSocketDidConnect
        webSocket.onDisconnect = webSocketDidDisconnect
        webSocket.onText = webSocketDidReceiveMessage
        webSocket.onData = webSocketDidReceiveData
        webSocket.onPong = webSocketDidReceivePong
    }
    
    private func async(block: @escaping () -> Void) {
        webSocket.callbackQueue.async(execute: block)
    }
}

// MARK: - Public API

extension Client {
    public func connect(completion: ClientConnected? = nil) {
        guard !isConnected else {
            completion?(true, nil)
            return
        }
        
        async { [weak self] in
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
        webSocket.disconnect()
        clientId = nil
    }
}

// MARK: - Channel

extension Client {
    public func subscribe(to channel: Channel) throws {
        guard isConnected else {
            throw Error.notConnected
        }
        
        try webSocketWrite(.subscribe, channel) { [weak self] in
            self?.weakChannels.append(WeakChannel(channel))
        }
    }
    
    func unsubscribe(channel: Channel) throws {
        guard isConnected else {
            return
        }
        
        try webSocketWrite(.unsubscribe, channel)
    }
    
    func remove(channel: Channel) {
        async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.weakChannels = self.weakChannels.filter { $0.channel != nil }
            try? self.unsubscribe(channel: channel)
        }
    }
}

// MARK: - Connection
extension Client {
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
        async { [weak self] in self?.webSocket.write(data: data, completion: completion) }
        print("🕸 ---> ", message.channel, message.clientId, message.ext)
    }
}

// MARK: - Receiving

extension Client {
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
            guard let json = try JSONSerialization.jsonObject(with: data) as? [JSON] else {
                return
            }
            
            let decoder = JSONDecoder()
            let messages = try decoder.decode([Message].self, from: data)
            
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
            print("🕸❌", #function, error)
        }
    }
    
    private func dispatchBayeuxChannel(with message: Message) -> Bool {
        guard let bayeuxChannel = BayeuxChannel(rawValue: message.channel) else {
            return false
        }
        
        if case .handshake = bayeuxChannel {
            handshake(with: message)
        }
        
        return true
    }
    
    private func dispatchData(with message: Message, in jsonData: Data) {
        print("🕸 <---", message.channel)
        
        weakChannels.forEach { weakChannel in
            if let channel = weakChannel.channel, channel.name.match(with: message.channel) {
                channel.subscription(jsonData)
            }
        }
    }
    
    private func handshake(with message: Message) {
        clientId = message.clientId
        notifyConnectedCallbacks(isConnected: true)
        
        weakChannels.forEach {
            if let channel = $0.channel {
                try? subscribe(to: channel)
            }
        }
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

// MARK: - Helpers

private final class WeakChannel {
    weak var channel: Channel?
    
    init(_ channel: Channel) {
        self.channel = channel
    }
}
