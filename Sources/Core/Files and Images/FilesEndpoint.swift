//
//  FilesEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 07/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya
import Swime

enum FilesEndpoint {
    case uploadFile(_ file: File)
    case deleteFile(_ fileURL: URL)
    case uploadImage(_ file: File)
    case deleteImage(_ imageURL: URL)
    case resizeImage(_ imageProcess: ImageProcess)
}

extension FilesEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case .uploadFile, .deleteFile:
            return "files/"
        case .uploadImage, .deleteImage, .resizeImage:
            return "images/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .uploadFile, .uploadImage:
            return .post
        case .deleteFile, .deleteImage:
            return .delete
        case .resizeImage:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .uploadFile(file):
            return .uploadMultipart([MultipartFormData(provider: .data(file.data),
                                                       name: "file",
                                                       fileName: file.name,
                                                       mimeType: mimeType)])
        case let .deleteFile(fileURL):
            return .requestParameters(parameters: ["url": fileURL], encoding: URLEncoding.default)
            
        case let .uploadImage(file):
            return .uploadMultipart([MultipartFormData(provider: .data(file.data),
                                                       name: "file",
                                                       fileName: file.name,
                                                       mimeType: mimeType)])
            
        case let .deleteImage(imageURL):
            return .requestParameters(parameters: ["url": imageURL], encoding: URLEncoding.default)
            
        case let .resizeImage(imageProcess):
            return .requestJSONEncodable(imageProcess)
        }
    }
}

extension FilesEndpoint {
    var mimeType: String {
        var mimeType: MimeType?
        
        switch self {
        case .uploadFile(let file), .uploadImage(let file):
            mimeType = file.mimeType ?? Swime.mimeType(data: file.data) ?? Swime.mimeType(fileName: file.name)
        default:
            break
        }
        
        return mimeType?.mime ?? "application/octet-stream"
    }
}

extension Swime {
    static func mimeType(fileName: String) -> MimeType? {
        guard let dotIndex = fileName.lastIndex(of: "."),
            (dotIndex.encodedOffset + 1) < fileName.count else {
            return nil
        }
        
        let extIndex = fileName.index(dotIndex, offsetBy: 1)
        let ext = fileName.suffix(from: extIndex).lowercased()
        
        for mime in MimeType.all {
            if mime.ext == ext {
                return mime
            }
        }
        
        return nil
    }
}
