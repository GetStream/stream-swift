//
//  BaseURL.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct BaseURL {
    static let placeholderURL = URL(string: "https://getstream.io")!
    
    let url: URL
    
    public init(location: Location = .default, service: Service = .api, version: String = "1.0") {
        url = URL(string: "https://\(location.rawValue)\(service.rawValue).stream-io-api.com/\(service.rawValue)/v\(version)/")!
    }
    
    public init(customURL: URL) {
        url = customURL
    }
    
    func endpointURLString(targetPath: String) -> String {
        return (targetPath.isEmpty ? url : url.appendingPathComponent(targetPath)).absoluteString
    }
}

extension BaseURL {
    public enum Service: String {
        case api
        case personalization
        case analytics
    }
    
    public enum Location: String {
        case `default` = ""
        case usEast = "us-east-"
        case europeWest = "eu-west-"
        case singapore = "singapore-"
    }
}

extension BaseURL: CustomStringConvertible {
    public var description: String {
        return url.absoluteString
    }
}
