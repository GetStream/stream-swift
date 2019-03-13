//
//  Swime+Extensions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 13/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import Swime

extension Swime {
    
    /// A simplified way to find a mime type by the given file name.
    public static func mimeType(byFileName fileName: String) -> MimeType? {
        if fileName.isEmpty {
            return nil
        }
        
        return mimeType(byFileExtension: (fileName as NSString).pathExtension)
    }
    
    /// A simplified way to find a mime type by the given file extension.
    public static func mimeType(byFileExtension fileExtension: String) -> MimeType? {
        if fileExtension.isEmpty {
            return nil
        }
        
        for mime in MimeType.all where mime.ext == fileExtension {
            return mime
        }
        
        return nil
    }
}
