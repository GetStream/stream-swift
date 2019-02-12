//
//  ReactionKind.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias ReactionKind = String

// MARK: - Extensions

extension ReactionKind {
    /// A shared Like type.
    public static let like: ReactionKind = "like"
    /// A shared Comment type.
    public static let comment: ReactionKind = "comment"
    /// A shared Repost type.
    public static let repost: ReactionKind = "repost"
}
