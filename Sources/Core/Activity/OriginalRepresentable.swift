//
//  OriginalRepresentable.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A protocol with a reference to the original object of itself.
public protocol OriginalRepresentable {}

extension OriginalRepresentable {
    /// The original object.
    ///
    /// In case if the reactionable object has a referance to the original reactionable object, then it should be redefined here.
    ///
    /// For example: Reposted activity should have a reference to the original activity
    /// and all reactions of a reposted activity should referenced to the original activity reactions.
    /// Usually the original activity should be stored in the activity object property as an enum
    /// and in this case the origin property could be redefined in this way:
    /// ```
    /// public var original: Activity {
    ///     if case .repost(let original) = object {
    ///         return original
    ///     }
    ///
    ///     return self
    /// }
    /// ```
    public var original: Self {
        return self
    }
}
