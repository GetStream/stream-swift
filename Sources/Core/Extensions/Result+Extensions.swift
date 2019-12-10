//
//  Result+Extensions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 10/12/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

extension Result {
    /// Get the error from the result if it failed.
    public var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        
        return nil
    }
}
