//
//  NotificationGroup.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public final class NotificationGroup<T: ActivityProtocol>: Group<T> {
    private enum CodingKeys: String, CodingKey {
        case isSeen = "is_seen"
        case isRead = "is_read"
    }
    
    public let isSeen: Bool
    public let isRead: Bool
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSeen = try container.decode(Bool.self, forKey: .isSeen)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        try super.init(from: decoder)
    }
}
