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
public typealias ActivitiesResult<T> = Result<[T], ClientError>
public typealias ActivitiesCompletion<T> = (_ result: ActivitiesResult<T>) -> Void
public typealias RemovedCompletion = (_ result: Result<String?, ClientError>) -> Void
public typealias StatusCodeCompletion = (_ result: Result<Int, ClientError>) -> Void
public typealias FollowersCompletion = (_ result: Result<[Follower], ClientError>) -> Void
public typealias Cancellable = Moya.Cancellable
