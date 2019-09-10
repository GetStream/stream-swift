//
//  GetStream.swift
//  Stream.io Inc
//
//  Created by Alexey Bukhtin on 06/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

public typealias JSON = [String: Any]
public typealias StatusCodeCompletion = (_ result: Result<Int, ClientError>) -> Void
public typealias Cancellable = Moya.Cancellable

final class SimpleCancellable: Cancellable {
    var isCancelled: Bool
    
    init(isCancelled: Bool = false) {
        self.isCancelled = isCancelled
    }
    
    func cancel() {
        isCancelled = true
    }
}

final class ProxyCancellable: Cancellable {
    var cancellable: Cancellable?
    
    var isCancelled: Bool {
        return cancellable?.isCancelled ?? false
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
