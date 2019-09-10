//
//  Client+Faye.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 30/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Faye

extension Client {
    /// Setup a Faye client.
    static var fayeClient: Faye.Client = {
        Faye.Client.config = .init(url: URL(string: "wss://faye.getstream.io/faye")!)
        return .shared
    }()
}
