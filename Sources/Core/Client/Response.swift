//
//  Response.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A general response object.
public struct Response<T: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case results
        case next
        case duration
        case unseenCount = "unseen"
        case unreadCount = "unread"
    }
    
    /// Response results of generic objects.
    public let results: [T]
    /// A pagination option for the next page of objects.
    public internal(set) var next: Pagination?
    /// A duration of the response.
    public internal(set) var duration: String?
    /// A number of unseen notifications.
    public internal(set) var unseenCount: Int?
    /// A number of unread notifications.
    public internal(set) var unreadCount: Int?
}
