//
//  GetStream.swift
//  Stream.io Inc
//
//  Created by Alexey Bukhtin on 06/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Result

public typealias Token = String
public typealias JSON = [String: Any]
public typealias StatusCodeCompletion = (_ result: Result<Int, ClientError>) -> Void
public typealias Cancellable = Moya.Cancellable
