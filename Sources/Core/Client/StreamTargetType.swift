//
//  StreamTargetType.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 17/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

protocol StreamTargetType: TargetType {
    var sampleJSON: String { get }
}

extension StreamTargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleJSON: String {
        return ""
    }
    
    var sampleData: Data {
        return sampleJSON.data(using: .utf8)!
    }
}
