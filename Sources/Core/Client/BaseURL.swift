//
//  BaseURL.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A base URL for the `Client`.
public struct BaseURL {
    static let placeholderURL = URL(string: "https://getstream.io")!
    
    let url: URL
    
    /// Create a base URL.
    ///
    /// - Parameters:
    ///     - location: a location of the server for the `Client`.
    ///     - service: a service type.
    ///     - version: a version of API.
    public init(location: Location = .default, service: Service = .api, version: String = "1.0") {
        url = URL(string: "https://\(location.rawValue)\(service.rawValue).stream-io-api.com/\(service.rawValue)/v\(version)/")!
    }
    
    /// Create a base URL with a custom URL.
    public init(customURL: URL) {
        url = customURL
    }
    
    func endpointURLString(targetPath: String) -> String {
        return (targetPath.isEmpty ? url : url.appendingPathComponent(targetPath)).absoluteString
    }
}

extension BaseURL {
    /// A service type.
    public enum Service: String {
        case api
        case personalization
        case analytics
    }
    
    /// A location type.
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
