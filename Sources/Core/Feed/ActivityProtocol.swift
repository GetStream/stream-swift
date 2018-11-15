//
//  ActivityProtocol.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 13/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public protocol ActivityProtocol: Codable {
    /// The Stream id of the activity.
    var id: UUID? { get }
    /// The actor performing the activity.
    var actor: String { get }
    /// The verb of the activity.
    var verb: String { get }
    /// The object of the activity.
    var object: String { get }
    /// The optional target of the activity.
    var target: String? { get }
    /// A unique ID from your application for this activity. IE: pin:1 or like:300.
    var foreignId: String? { get }
    /// The optional time of the activity, isoformat. Default is the current time.
    var time: Date? { get }
    /// An array allows you to specify a list of feeds to which the activity should be copied.
    /// One way to think about it is as the CC functionality of email.
    var feedIds: [FeedId]? { get }
}
