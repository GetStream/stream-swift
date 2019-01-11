//
//  Response.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public struct Response<T: Decodable>: Decodable {
    public let results: [T]
    public internal(set) var next: Pagination?
    public let duration: String?
}
