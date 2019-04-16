//
//  NotificationGroup.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A notification group.
public final class NotificationGroup<T: ActivityProtocol>: Group<T> {
    private enum CodingKeys: String, CodingKey {
        case isSeen = "is_seen"
        case isRead = "is_read"
    }
    
    /// True if the notification group is seen.
    public let isSeen: Bool
    /// True if the notification group is read.
    public let isRead: Bool
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSeen = try container.decode(Bool.self, forKey: .isSeen)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        try super.init(from: decoder)
    }
}
