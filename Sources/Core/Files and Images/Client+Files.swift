//
//  Client+Files.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 07/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result
import UIKit
import Swime

extension Client {
    
    @discardableResult
    public func upload(file: File, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.uploadFile(file)) {
            $0.parseUpload(completion)
        }
    }
    
    @discardableResult
    public func delete(fileURL: URL, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.deleteFile(fileURL)) {
            $0.parseStatusCode(completion)
        }
    }
}

// MARK: - Images

extension Client {

    @discardableResult
    public func upload(image: File, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.uploadImage(image)) {
            $0.parseUpload(completion)
        }
    }
    
    @discardableResult
    public func delete(imageURL: URL, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.deleteImage(imageURL)) {
            $0.parseStatusCode(completion)
        }
    }
    
    @discardableResult
    public func resizeImage(imageProcess: ImageProcess, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.resizeImage(imageProcess)) {
            $0.parseUpload(completion)
        }
    }
}

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
