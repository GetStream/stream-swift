//
//  Comment.swift
//  GetStreamExample
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Alexey Bukhtin. All rights reserved.
//

import Foundation
import GetStream

struct Comment: ReactionExtraDataProtocol {
    let text: String
}

extension ReactionKind {
    static let like = "like"
    static let comment = "comment"
}
