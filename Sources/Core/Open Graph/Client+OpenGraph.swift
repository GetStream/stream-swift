//
//  Client+OpenGraph.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

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
                let ogResponse = try JSONDecoder().decode(OGResponse.self, from: response.data)
                
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
    
    public private(set) var title: String?
    public private(set) var type: String?
    public private(set) var url: URL?
    public private(set) var site: String?
    public private(set) var siteName: String?
    public private(set) var description: String?
    public private(set) var determiner: String?
    public private(set) var locale: String?
    public private(set) var images: [OGImageResponse]?
    public private(set) var videos: [OGVideoResponse]?
    public private(set) var audios: [OGAudioResponse]?
}

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
    public private(set) var width: String?
    public private(set) var height: String?
    public private(set) var type: String?
    public private(set) var alt: String?
}

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
    public private(set) var width: String?
    public private(set) var height: String?
    public private(set) var type: String?
    public private(set) var alt: String?
}

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
