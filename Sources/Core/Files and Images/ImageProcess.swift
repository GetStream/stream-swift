//
//  ImageProcess.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 10/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// An image process option type.
public struct ImageProcess: Codable {
    private enum CodingKeys: String, CodingKey {
        case url
        case resize = "resize"
        case crop = "crop"
        case width = "w"
        case height = "h"
    }
    
    /// URL of the image to process. This is the URL returned by the `UploadResult` request.
    let url: URL
    /// Strategy used to adapt the image the new dimensions. Allowed values are: `clip`, `crop`, `scale`, `fill`.
    let resize: ResizeStrategy
    /// Cropping modes as a comma separated list. Allowed values are top, bottom, left, right, center.
    let crop: String
    /// Width of the processed image.
    let width: Int
    /// Height of the processed image.
    let height: Int
    
    public init(url: URL, resize: ResizeStrategy = .clip, crop: CropMode = .center, width: Int, height: Int) {
        self.url = url
        self.resize = resize
        self.crop = crop.description
        self.width = width
        self.height = height
    }
}

extension ImageProcess {
    public enum ResizeStrategy: String, Codable {
        case clip
        case crop
        case scale
        case fill
    }
}

extension ImageProcess {
    public struct CropMode: OptionSet, Codable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let top = CropMode(rawValue: 1 << 0)
        public static let bottom = CropMode(rawValue: 1 << 1)
        public static let left = CropMode(rawValue: 1 << 2)
        public static let right = CropMode(rawValue: 1 << 3)
        public static let center = CropMode(rawValue: 1 << 4)
        
        var description: String {
            var crops = [String]()
            
            if self.contains(.top) {
                crops.append("top")
            }
            
            if self.contains(.bottom) {
                crops.append("bottom")
            }
            
            if self.contains(.left) {
                crops.append("left")
            }
            
            if self.contains(.right) {
                crops.append("right")
            }
            
            if self.contains(.center) {
                crops.append("center")
            }
            
            return crops.joined(separator: ",")
        }
    }
}
