//
//  Bundle+Extensions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 28/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Bundle {
    public static let streamAPIKey = "Stream API Key"
    public static let streamAppId = "Stream App Id"
    public static let streamToken = "Stream Token"
    public typealias StreamClientSetup = (_ apiKey: String, _ appId: String, _ token: Token) -> Void
    
    /// Setup the Client with keys from the bundle.
    ///
    /// - Note: The example how to setup Client with enabled logs.
    /// ```
    /// Bundle.main.setupStreamClient {
    ///     Client.config = .init(apiKey: $0, appId: $1, token: $2, logsEnabled: true)
    /// }
    /// ```
    ///
    /// - Parameter setup: a block with Stream keys to setup the Client with custom parameters.
    public func setupStreamClient(_ setup: StreamClientSetup? = nil) {
        guard let apiKey = streamValue(for: Bundle.streamAPIKey),
            let appId = streamValue(for: Bundle.streamAppId),
            let token: Token = streamValue(for: Bundle.streamToken),
            token.isValid else {
                print("⚠️ Stream bundle keys not found")
                return
        }
        
        if let setup = setup {
            setup(apiKey, appId, token)
        } else {
            Client.config = .init(apiKey: apiKey, appId: appId, token: token)
        }
    }
    
    private func streamValue(for key: String) -> String? {
        if let value = infoDictionary?[key] as? String, !value.isEmpty {
            return value
        }
        
        return nil
    }
}
