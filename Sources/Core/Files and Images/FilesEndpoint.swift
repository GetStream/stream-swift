//
//  FilesEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 07/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum FilesEndpoint {
    case uploadFile(_ data: Data)
    case deleteFile(_ fileURL: URL)
    case uploadImage(_ data: Data)
    case deleteImage(_ imageURL: URL)
    case resizeImage(_ imageProcess: ImageProcess)
}

extension FilesEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
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
        case let .uploadFile(data):
            return .uploadMultipart([MultipartFormData(provider: .data(data), name: "file")])
            
        case let .deleteFile(fileURL):
            return .requestParameters(parameters: ["url": fileURL], encoding: URLEncoding.default)
            
        case let .uploadImage(data):
            return .uploadMultipart([MultipartFormData(provider: .data(data), name: "file")])
            
        case let .deleteImage(imageURL):
            return .requestParameters(parameters: ["url": imageURL], encoding: URLEncoding.default)
            
        case let .resizeImage(imageProcess):
            return .requestJSONEncodable(imageProcess)
        }
    }
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleData: Data {
        return Data()
    }
}
