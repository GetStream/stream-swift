//
//  StreamTargetType.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 17/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

protocol StreamTargetType: TargetType {}

extension StreamTargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleData: Data {
        return Data()
    }
}
