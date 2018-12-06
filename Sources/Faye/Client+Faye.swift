//
//  Client+Faye.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 30/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Faye
import Result

public typealias SubscribedChannel = Faye.Channel
public typealias Subscription<T: ActivityProtocol> = (_ result: Result<SubscriptionResponse<T>, DecodingError>) -> Void

fileprivate var fayeClientKey: UInt8 = 0
fileprivate var fayeFeedChannelKey: UInt8 = 0

extension Client {
    
	    var fayeClient: Faye.Client {
        if let fayeClient = objc_getAssociatedObject(self, &fayeClientKey) as? Faye.Client {
            return fayeClient
        }
        
        let url = URL(string: "wss://faye.getstream.io/faye")!
        let fayeClient = Faye.Client(url: url)
        objc_setAssociatedObject(self, &fayeClientKey, fayeClient, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return fayeClient
    }
}

extension Feed {
    public func subscribe<T: ActivityProtocol>(typeOf type: T.Type,
                                               decoder: JSONDecoder = JSONDecoder.Stream.default,
                                               subscriptionResult: @escaping Subscription<T>) -> SubscribedChannel {
        let channel = Channel(notificationChannelName, client: client.fayeClient) { data  in
            do {
                let response = try decoder.decode(SubscriptionResponse<T>.self, from: data)
                subscriptionResult(.success(response))
            } catch let error as DecodingError {
                subscriptionResult(.failure(error))
            } catch {
                print("❌", #function, error)
            }
        }
        
        channel.ext = ["api_key": client.apiKey,
                       "signature": client.token,
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

public struct SubscriptionResponse<T: ActivityProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case feedId = "feed"
        case deletedActivitiesIds = "deleted"
        case newActivities = "new"
    }
    
    public let feedId: FeedId
    public let deletedActivitiesIds: [String]
    public let newActivities: [T]
}
