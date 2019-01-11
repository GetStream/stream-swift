//
//  Client+Files.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 07/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Result

// MARK: - Client Files

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

// MARK: - Client Images

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
        if imageProcess.height <= 0 {
            completion(.failure(.parameterInvalid(\ImageProcess.height)))
            return SimpleCancellable()
        }
        
        if imageProcess.width <= 0 {
            completion(.failure(.parameterInvalid(\ImageProcess.width)))
            return SimpleCancellable()
        }
        
        return request(endpoint: FilesEndpoint.resizeImage(imageProcess)) {
            $0.parseUpload(completion)
        }
    }
}
