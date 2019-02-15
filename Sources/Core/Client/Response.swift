//
//  Response.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public struct Response<T: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case results
        case next
        case duration
        case unseenCount = "unseen"
        case unreadCount = "unread"
    }
    
    public let results: [T]
    public internal(set) var next: Pagination?
    public internal(set) var duration: String?
    public internal(set) var unseenCount: Int?
    public internal(set) var unreadCount: Int?
}
