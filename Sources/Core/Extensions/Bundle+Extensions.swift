//
//  Bundle+Extensions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 28/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Bundle {
    enum StreamKey: String {
        case streamAPIKey = "Stream API Key"
        case streamAppId = "Stream App Id"
        case streamToken = "Stream Token"
    }
    
    /// API key from the bundle.
    public var streamAPIKey: String? {
        return streamValue(for: .streamAPIKey)
    }
    
    /// App id from the bundle.
    public var streamAppId: String? {
        return streamValue(for: .streamAppId)
    }
    
    /// Token from the bundle.
    public var streamToken: String? {
        return streamValue(for: .streamToken)
    }
    
    private func streamValue(for key: StreamKey) -> String? {
        if let value = infoDictionary?[key.rawValue] as? String, !value.isEmpty {
            return value
        }
        
        return nil
    }
}
