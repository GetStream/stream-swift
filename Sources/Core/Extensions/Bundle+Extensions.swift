//
//  Bundle+Extensions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 28/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Bundle {
    public enum StreamKey: String {
        case streamAPIKey = "Stream API Key"
        case streamAppId = "Stream App Id"
        case streamToken = "Stream Token"
    }
    
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
    /// - Parameters:
    ///     - token: a token to use instead of a value from the Bundle.
    ///              It's useful, when your app is getting Token from your backend.
    ///     - setup: a block with Stream keys to setup the Client with custom parameters.
    public func setupStreamClient(_ token: Token? = nil, _ setup: StreamClientSetup? = nil) {
        guard let apiKey = streamValue(for: .streamAPIKey),
            let appId = streamValue(for: .streamAppId),
            let token: Token = token ?? streamValue(for: .streamToken),
            token.isValid else {
                print("⚠️ Stream bundle keys not found. Check values:\n",
                      StreamKey.streamAPIKey.rawValue, "-", streamValue(for: .streamAPIKey) ?? "🔴 <NotFound>", "\n",
                      StreamKey.streamAppId.rawValue, "-", streamValue(for: .streamAppId) ?? "🔴 <NotFound>", "\n",
                      StreamKey.streamToken.rawValue, "-", streamValue(for: .streamToken) ?? "🔴 <NotFound>", "\n",
                      "Does Token valid?", (streamValue(for: .streamToken)?.isValid ?? "🔴 false"))
                return
        }
        
        if let setup = setup {
            setup(apiKey, appId, token)
        } else {
            Client.config = .init(apiKey: apiKey, appId: appId, token: token)
        }
    }
    
    private func streamValue(for key: StreamKey) -> String? {
        if let value = infoDictionary?[key.rawValue] as? String, !value.isEmpty {
            return value
        }
        
        return nil
    }
}
