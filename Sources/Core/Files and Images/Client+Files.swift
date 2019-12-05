//
//  Client+Files.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 07/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

// MARK: - Client Files

extension Client {
    
    /// Upload a `File`.
    @discardableResult
    public func upload(file: File, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.uploadFile(file)) { [weak self] result in
            if let self = self {
                result.parseUpload(self.callbackQueue, completion)
            }
        }
    }
    
    /// Upload a list of `File`.
    @discardableResult
    public func upload(files: [File], completion: @escaping MultipleUploadCompletion) -> Cancellable {
        return upload(files: files, endpoint: { FilesEndpoint.uploadFile($0) }, completion: completion)
    }
    
    /// Delete a file with a given file URL.
    @discardableResult
    public func delete(fileURL: URL, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.deleteFile(fileURL)) { [weak self] result in
            if let self = self {
                result.parseStatusCode(self.callbackQueue, completion)
            }
        }
    }
}

// MARK: - Client Images

extension Client {
    
    /// Upload an image file.
    @discardableResult
    public func upload(image: File, completion: @escaping UploadCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.uploadImage(image)) { [weak self] result in
            if let self = self {
                result.parseUpload(self.callbackQueue, completion)
            }
        }
    }
    
    /// Upload a list of image files.
    @discardableResult
    public func upload(images: [File], completion: @escaping MultipleUploadCompletion) -> Cancellable {
        return upload(files: images, endpoint: { FilesEndpoint.uploadImage($0) }, completion: completion)
    }
    
    /// Delete an image file with a given image URL.
    @discardableResult
    public func delete(imageURL: URL, completion: @escaping StatusCodeCompletion) -> Cancellable {
        return request(endpoint: FilesEndpoint.deleteImage(imageURL)) { [weak self] result in
            if let self = self {
                result.parseStatusCode(self.callbackQueue, completion)
            }
        }
    }
    
    /// Upload and resize an image with a given image process options.
    @discardableResult
    public func resizeImage(imageProcess: ImageProcess, completion: @escaping UploadCompletion) -> Cancellable {
        if imageProcess.height <= 0 {
            callbackQueue.async { completion(.failure(.parameterInvalid("ImageProcess.height"))) }
            return SimpleCancellable()
        }
        
        if imageProcess.width <= 0 {
            callbackQueue.async { completion(.failure(.parameterInvalid("ImageProcess.width"))) }
            return SimpleCancellable()
        }
        
        return request(endpoint: FilesEndpoint.resizeImage(imageProcess)) { [weak self] result in
            if let self = self {
                result.parseUpload(self.callbackQueue, completion)
            }
        }
    }
}

// MARK: - Client Multiple Upload

extension Client {
    private func upload(files: [File],
                        endpoint: @escaping (_ file: File) -> TargetType,
                        completion: @escaping MultipleUploadCompletion) -> Cancellable {
        guard files.count > 0 else {
            return SimpleCancellable(isCancelled: true)
        }
        
        let proxyCancellable = ProxyCancellable()
        var urls: [URL] = []
        
        func request(fileIndex: Int) {
            workingQueue.async { [weak self] in
                if proxyCancellable.isCancelled {
                    return
                }
                
                guard fileIndex < files.count else {
                    self?.callbackQueue.async { completion(.success(urls)) }
                    return
                }
                
                proxyCancellable.cancellable = self?.request(endpoint: endpoint(files[fileIndex])) { result in
                    if let self = self {
                        result.parseUpload(self.workingQueue) { result in
                            do {
                                let url = try result.get()
                                urls.append(url)
                                request(fileIndex: fileIndex + 1)
                            } catch let clientError as ClientError {
                                completion(.failure(clientError))
                            } catch {
                                completion(.failure(.unexpectedError(error)))
                            }
                        }
                    }
                }
            }
        }
        
        request(fileIndex: 0)
        
        return proxyCancellable
    }
}
