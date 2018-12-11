//
//  Client+Files.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 07/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

// MARK: - Files

extension Client {
    
    @discardableResult
    public func upload(data: Data, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.uploadFile(data)) {
            Client.parseUploadResponse($0, completion: completion)
        }
    }
    
    @discardableResult
    public func delete(fileURL: URL, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.deleteFile(fileURL)) {
            Client.parseStatusCodeResponse($0, completion: completion)
        }
    }
}

// MARK: - Images

extension Client {

    @discardableResult
    public func upload(imageData: Data, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.uploadImage(imageData)) {
            Client.parseUploadResponse($0, completion: completion)
        }
    }
    
    @discardableResult
    public func delete(imageURL: URL, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.deleteImage(imageURL)) {
            Client.parseStatusCodeResponse($0, completion: completion)
        }
    }
    
    @discardableResult
    public func resizeImage(imageProcess: ImageProcess, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.resizeImage(imageProcess), completion: {
            Client.parseUploadResponse($0, completion: completion)
        })
    }
}
