//
//  Client+Faye.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 30/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Faye

public typealias SubscriptionChannel = Faye.Channel

fileprivate var fayeClientKey: UInt8 = 0
fileprivate var fayeFeedChannelKey: UInt8 = 0

extension Client {
    
	    var fayeClient: Faye.Client {
        if let fayeClient = objc_getAssociatedObject(self, &fayeClientKey) as? Faye.Client {
            return fayeClient
        }
        
        let url = URL(string: "wss://faye.getstream.io/faye")!
        let authPlugin = ClientAuthFayePlugin(client: self)
        let fayeClient = Faye.Client(url: url)
        objc_setAssociatedObject(self, &fayeClientKey, fayeClient, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return fayeClient
    }
}

extension Feed {
    
    public func subscribe(completion: @escaping ChannelSubscription) -> SubscriptionChannel {
        let channel = Channel(notificationChannelName,
                              client: client.fayeClient,
                              subscription: completion)
        
        channel.ext = ["api_key": client.apiKey,
                       "signature": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmZWVkX2lkIjoiKiIsInJlc291cmNlIjoiKiIsImFjdGlvbiI6IioiLCJ1c2VyX2lkIjoiZXJpYyJ9.Lg4o5xfw70hLjphb1hHE6uCgnfoc7X2ASH3c8kf04lk",
                       "user_id": notificationChannelName]
        
        client.fayeClient.connect { isConnected, error in
            if isConnected {
                do {
                    try self.client.fayeClient.subscribe(to: channel)
                } catch {
                    print("❌", #function, error)
                }
            } else {
                print("❌", #function, error)
            }
        }
        
        return channel
    }
    
    var notificationChannelName: ChannelName {
        return "site-\(client.appId)-feed-\(feedId.together)"
    }
}
