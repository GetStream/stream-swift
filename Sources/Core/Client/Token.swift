//
//  Token.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 03/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A JWT token including a signature generated with the HS256 algorithm.
/// You can find more information on JWT at https://jwt.io/introduction
public typealias Token = String

extension Token {
    
    var isValid: Bool {
        return payload != nil
    }
    
    var payload: JSON? {
        let parts = split(separator: ".")
        
        if parts.count == 3,
            let payloadData = jwtDecodeBase64(String(parts[1])),
            let json = (try? JSONSerialization.jsonObject(with: payloadData)) as? JSON {
            return json
        }
        
        return nil
    }
    
    /// A user id from the Token.
    public var userId: String? {
        return payload?["user_id"] as? String
    }
    
    private func jwtDecodeBase64(_ input: String) -> Data? {
        let removeEndingCount = input.count % 4
        let ending = removeEndingCount > 0 ? String(repeating: "=", count: 4 - removeEndingCount) : ""
        let base64 = input.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/") + ending
        
        return Data(base64Encoded: base64)
    }
}
