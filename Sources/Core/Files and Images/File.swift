//
//  File.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import UIKit
import Swime

public struct File {
    let name: String
    let data: Data
    var mimeType: MimeType?
    
    /// Create a File.
    ///
    /// - Parameters:
    ///     - name: the name of the file.
    ///     - data: the data of the file.
    public init(name: String, data: Data) {
        self.name = name.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        self.data = data
    }
}

public extension File {
    
    /// Create a File from a given image.
    ///
    /// - Parameters:
    ///     - name: the name of the image.
    ///     - jpegImage: the image, that would be converted to a JPEG data.
    ///     - compressionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0.
    ///                           The value 0.0 represents the maximum compression (or lowest quality)
    ///                           while the value 1.0 represents the least compression (or best quality). Default: 0.9.
    public init?(name: String, jpegImage: UIImage, compressionQuality: CGFloat = 0.9) {
        guard let data = jpegImage.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        self.init(name: name, data: data)
        mimeType = Swime.mimeType(ext: "jpg")
    }
    
    /// Create a File from a given image.
    ///
    /// - Parameters:
    ///     - name: the name of the image.
    ///     - pngImage: the image, that would be converted to a PNG data.
    public init?(name: String, pngImage: UIImage) {
        guard let data = pngImage.pngData() else {
            return nil
        }
        
        self.init(name: name, data: data)
        mimeType = Swime.mimeType(ext: "png")
    }
}

// MARK: - File

extension Swime {
    static func mimeType(ext: String) -> MimeType? {
        if ext.isEmpty {
            return nil
        }
        
        for mime in MimeType.all {
            if mime.ext == ext {
                return mime
            }
        }
        
        return nil
    }
}
