//
//  SubscriptionResponse.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 18/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A responce object of changes from a subscription.
public struct SubscriptionResponse<T: ActivityProtocol>: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case feedId = "feed"
        case deletedActivitiesIds = "deleted"
        case newActivities = "new"
    }
    
    /// A feed of the subscription.
    public var feed: Feed?
    
    /// A `FeedId` of changes.
    public let feedId: FeedId
    
    /// A list of deleted activities ids.
    public let deletedActivitiesIds: [String]
    
    /// A list of new activities.
    public let newActivities: [T]
}
