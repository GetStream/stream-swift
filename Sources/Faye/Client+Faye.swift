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

// MARK: - Client + Faye

fileprivate var fayeClientKey: UInt8 = 0
fileprivate var fayeFeedChannelKey: UInt8 = 0

extension Client {
    /// Setup a Faye client.
    fileprivate var fayeClient: Faye.Client {
        if let fayeClient = objc_getAssociatedObject(self, &fayeClientKey) as? Faye.Client {
            return fayeClient
        }
        
        let url = URL(string: "wss://faye.getstream.io/faye")!
        let fayeClient = Faye.Client(url: url)
        objc_setAssociatedObject(self, &fayeClientKey, fayeClient, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return fayeClient
    }
}

// MARK: - Feed Subscription

public typealias Subscription<T: ActivityProtocol> = (_ result: Result<SubscriptionResponse<T>, SubscriptionError>) -> Void

public enum SubscriptionError: Error {
    case fayeClient(_ error: Faye.Client.Error)
    case decoding(_ error: DecodingError)
    case unexpected(_ error: Error)
}

extension Feed {
    
    /// Subscribe for the updates of the given activity type of `ActivityProtocol`.
    ///
    /// - Parameters:
    ///     - type: an `ActivityProtocol` of activities.
    ///     - decoder: a custom decoder for the given activity type.
    ///     - subscription: a subscription block with changes.
    ///                     It will retrun a `Result` with `SubscriptionResponse` or `DecodingError`.
    ///
    /// - Returns: a `SubscribedChannel` keep the subscription util it will be deinit.
    ///            Store the object in a variable for the getting updates and then set it to nil to unsubscribe.
    public func subscribe<T: ActivityProtocol>(typeOf type: T.Type,
                                               decoder: JSONDecoder = JSONDecoder.stream,
                                               subscription: @escaping Subscription<T>) -> SubscribedChannel {
        let channel = Channel(notificationChannelName, client: client.fayeClient) { data  in
            do {
                var response = try decoder.decode(SubscriptionResponse<T>.self, from: data)
                response.feed = self
                subscription(.success(response))
                
            } catch let error as DecodingError {
                print("❌", #function, error)
                subscription(.failure(.decoding(error)))
                
            } catch {
                print("❌", #function, error)
                subscription(.failure(.unexpected(error)))
            }
        }
        
        channel.ext = ["api_key": client.apiKey, "signature": client.token, "user_id": notificationChannelName]
        
        do {
            try client.fayeClient.subscribe(to: channel)
            
        } catch let error as Faye.Client.Error {
            if case .notConnected = error {
                client.fayeClient.connect()
            } else {
                print("❌", #function, error)
                subscription(.failure(.fayeClient(error)))
            }
            
        } catch {
            print("❌", #function, error)
            subscription(.failure(.unexpected(error)))
        }
        
        return SubscribedChannel(channel)
    }
    
    /// A notification channel name.
    var notificationChannelName: ChannelName {
        return "site-\(client.appId)-feed-\(feedId.together)"
    }
}

// MARK: - Subscription Response

/// A responce object of changes from a subscription.
public struct SubscriptionResponse<T: ActivityProtocol>: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case feedId = "feed"
        case deletedActivitiesIds = "deleted"
        case newActivities = "new"
    }
    
    // A feed of the subscription.
    public var feed: Feed?
    
    /// A `FeedId` of changes.
    public let feedId: FeedId
    
    /// A list of deleted activities ids.
    public let deletedActivitiesIds: [String]
    
    /// A list of new activities.
    public let newActivities: [T]
}

// MARK: - Subscribed Channel

/// A subscribed channel holder.
public final class SubscribedChannel {
    private let channel: Channel
    
    public init(_ channel: Channel) {
        self.channel = channel
    }
    
    deinit {
        channel.unsubscribe()
    }
}
