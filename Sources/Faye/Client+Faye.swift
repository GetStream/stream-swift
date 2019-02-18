//
//  Client+Faye.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 30/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Faye
import Result

fileprivate var fayeClientKey: UInt8 = 0

extension Client {
    /// Setup a Faye client.
    var fayeClient: Faye.Client {
        if let fayeClient = objc_getAssociatedObject(self, &fayeClientKey) as? Faye.Client {
            return fayeClient
        }
        
        let url = URL(string: "wss://faye.getstream.io/faye")!
        let fayeClient = Faye.Client(url: url)
        objc_setAssociatedObject(self, &fayeClientKey, fayeClient, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return fayeClient
    }
}
