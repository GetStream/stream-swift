//
//  Moya+Task.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 15/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

extension Task {
    func requestJSONEncodable(encodable: Encodable, urlParameters: [String : Any]) -> Task {
        return .requestJSONEncodable(encodable)
    }
}
