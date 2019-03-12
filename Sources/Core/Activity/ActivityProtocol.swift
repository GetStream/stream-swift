//
//  ActivityProtocol.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 13/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A verb type of the Activity.
/// - Note: Verb type is useful for the making of static verb strings in the extension of the Verb type.
public typealias Verb = String

/// A protocol for the Activity type.
public protocol ActivityProtocol: Enrichable, Reactionable, OriginalRepresentable {
    associatedtype ActorType = Enrichable
    associatedtype ObjectType = Enrichable
    
    /// The Stream id of the activity.
    var id: String { get set }
    /// The actor performing the activity.
    var actor: ActorType { get }
    /// The verb of the activity.
    var verb: Verb { get }
    /// The object of the activity.
    /// - Note: It shouldn't be empty.
    var object: ObjectType { get }
    /// A unique ID from your application for this activity. IE: pin:1 or like:300.
    var foreignId: String? { get set }
    /// The optional time of the activity, isoformat. Default is the current time.
    var time: Date? { get set }
    /// An array allows you to specify a list of feeds to which the activity should be copied.
    /// One way to think about it is as the CC functionality of email.
    var feedIds: FeedIds? { get set }
}

// MARK: - Enrichable

extension ActivityProtocol {
    /// The activity is enrichable and here is a referenceId by default.
    /// For example, in case when you need to make a repost activity where `object` would be the original activity.
    public var referenceId: String {
        return "SA:\(id)"
    }
}
