//
//  Enrichable.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A protocol for enrichable objects.
public protocol Enrichable: Codable {
    /// A referenceId for an enrichable object.
    var referenceId: String { get }
}

// MARK: - String Enrichable

extension String: Enrichable {
    public var referenceId: String {
        return self
    }
}
