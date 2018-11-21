//
//  UUID+Extensions.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 21/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest

extension UUID {
    static let test1: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001").require()
    static let test2: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000002").require()
}
