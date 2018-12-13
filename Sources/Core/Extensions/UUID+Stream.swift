//
//  UUID+Stream.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

extension UUID {
    /// Returns a string created from the UUID, such as “e621e1f8-c36c-495a-93fc-0c247a3e6e5f”
    public var lowercasedString: String {
        return uuidString.lowercased()
    }
}
