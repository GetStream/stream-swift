//
//  OpenGraphEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum OpenGraphEndpoint {
    case og(_ ulr: URL)
}

extension OpenGraphEndpoint: StreamTargetType {
    
    var path: String {
        return "og/"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .og(let url):
            return .requestParameters(parameters: ["url": url], encoding: URLEncoding.default)
        }
    }
}
