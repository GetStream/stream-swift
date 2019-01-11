//
//  MoyaError+ClientError.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 09/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

// MARK: - Moya Client Error

extension MoyaError {
    var clientError: ClientError {
        return .network(errorDescription ?? "Unknown", self)
    }
}
