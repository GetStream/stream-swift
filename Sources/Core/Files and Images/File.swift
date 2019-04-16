//
//  File.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import Swime

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit.UIImage
    public typealias Image = UIImage
#elseif os(macOS)
    import AppKit.NSImage
    public typealias Image = NSImage
#endif

/// A file type.
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
    init?(name: String, jpegImage: Image, compressionQuality: CGFloat = 0.9) {
        guard let data = jpegImage.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        self.init(name: name, data: data)
        mimeType = Swime.mimeType(byFileExtension: "jpg")
    }
    
    /// Create a File from a given image.
    ///
    /// - Parameters:
    ///     - name: the name of the image.
    ///     - pngImage: the image, that would be converted to a PNG data.
    init?(name: String, pngImage: Image) {
        guard let data = pngImage.pngData() else {
            return nil
        }
        
        self.init(name: name, data: data)
        mimeType = Swime.mimeType(byFileExtension: "png")
    }
    
    /// A helper function to create `File`'s from images in working thread.
    ///
    /// - Parameters:
    ///     - images: a list of `Image`'s.
    ///     - process: a process block to create a `File` from a given `Image`. The block can return nil an image needs to skip.
    ///     - completion: a completion block with a list of `File`'s (could be empty, if images didn't converted to `File`'s. ).
    static func files(from images: [Image],
                             process: @escaping (_ index: Int, _ image: Image) -> File?,
                             completion: @escaping (_ files: [File]) -> Void) {
        guard images.count > 0 else {
            completion([])
            return
        }
        
        DispatchQueue(label: "io.getstream.File").async {
            var files: [File] = []
            
            images.enumerated().forEach { index, image in
                if let file = process(index, image) {
                    files.append(file)
                }
            }
            
            DispatchQueue.main.async { completion(files) }
        }
    }
}

// MARK: - macOS Image API compatibility.

#if os(macOS)
extension Image {
    func pngData() -> Data? {
        return representation(using: .png)
    }
    
    func jpegData(compressionQuality: CGFloat) -> Data? {
        return representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
    
    private func representation(using fileType: NSBitmapImageRep.FileType,
                                properties: [NSBitmapImageRep.PropertyKey: Any] = [:]) -> Data? {
        var imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        if let cgImage = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            return imageRep.representation(using: fileType, properties: properties)
        }
        
        return nil
    }
}
#endif
