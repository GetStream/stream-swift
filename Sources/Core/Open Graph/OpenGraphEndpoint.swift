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

extension OpenGraphEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
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
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleData: Data {
        return Data()
    }
}
