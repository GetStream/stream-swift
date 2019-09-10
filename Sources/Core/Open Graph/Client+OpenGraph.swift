//
//  Client+OpenGraph.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import CoreGraphics.CGBase

/// An Open Graph completion block.
public typealias OGCompletion = (_ result: Result<OGResponse, ClientError>) -> Void

// MARK: - Client Open Graph

extension Client {
    
    /// The Open Graph can be used to scrape (GET) open graph data from a website.
    ///
    /// - Parameters:
    ///     - url: URL to scrape.
    @discardableResult
    public func og(url: URL, completion: @escaping OGCompletion) -> Cancellable {
        return request(endpoint: OpenGraphEndpoint.og(url)) { [weak self] result in
            result.parse(block: {
                let response = try result.get()
                var ogResponse = try JSONDecoder().decode(OGResponse.self, from: response.data)
                
                if ogResponse.url == nil {
                    ogResponse.url = url
                }
                
                if let self = self  {
                    self.callbackQueue.async { completion(.success(ogResponse)) }
                }
                
            }, catch: { error in
                if let self = self  {
                    self.callbackQueue.async { completion(.failure(error)) }
                }
            })
        }
    }
}

/// An Open Graph response.
public struct OGResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case title
        case type
        case url
        case site
        case siteName = "site_name"
        case description
        case determiner
        case locale
        case images
        case videos
        case audios
    }
    
    /// A title.
    public private(set) var title: String?
    /// A type.
    public private(set) var type: String?
    /// An URL.
    public internal(set) var url: URL?
    /// A site base URL.
    public private(set) var site: String?
    /// A site name.
    public private(set) var siteName: String?
    /// A description.
    public private(set) var description: String?
    /// A determiner.
    public private(set) var determiner: String?
    /// A locale.
    public private(set) var locale: String?
    /// An images.
    public private(set) var images: [OGImageResponse]?
    /// A videos.
    public private(set) var videos: [OGVideoResponse]?
    /// An audios.
    public private(set) var audios: [OGAudioResponse]?
}

/// An Open Graph image response.
public struct OGImageResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case image
        case url
        case secureURL = "secure_url"
        case width
        case height
        case type
        case alt
    }
    
    public private(set) var image: String?
    public private(set) var url: URL?
    public private(set) var secureURL: String?
    public private(set) var width: Int?
    public private(set) var height: Int?
    public private(set) var type: String?
    public private(set) var alt: String?
}

/// An Open Graph video response.
public struct OGVideoResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case image
        case url
        case secureURL = "secure_url"
        case width
        case height
        case type
        case alt
    }
    
    public private(set) var image: String?
    public private(set) var url: URL?
    public private(set) var secureURL: String?
    public private(set) var width: StringOrInt?
    public private(set) var height: StringOrInt?
    public private(set) var type: String?
    public private(set) var alt: String?
    
    public var size: CGSize {
        guard let widthEnum = width, let heightEnum = height else {
            return .zero
        }
        
        var widthInt: Int = 0
        var heightInt: Int = 0
        
        switch widthEnum {
        case .string(let widthValue):
            if case .string(let heightValue) = heightEnum {
                widthInt = Int(widthValue) ?? 0
                heightInt = Int(heightValue) ?? 0
            }
        case .int(let widthValue):
            if case .int(let heightValue) = heightEnum {
                widthInt = widthValue
                heightInt = heightValue
            }
        }
        
        return CGSize(width: CGFloat(widthInt), height: CGFloat(heightInt))
    }
}

/// An Open Graph audio response.
public struct OGAudioResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case audio
        case url
        case secureURL = "secure_url"
        case type
    }
    
    public private(set) var audio: String?
    public private(set) var url: URL?
    public private(set) var secureURL: String?
    public private(set) var type: String?
}

/// An enum of string or int types.
public enum StringOrInt: Codable {
    case string(_ value: String)
    case int(_ value: Int)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else {
            self = try .string(container.decode(String.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
}
