//
//  Dictionary+Extensions.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation


/// Creates a dictionary by merging the given dictionary into this
/// dictionary, replacing values with values of the other dictionary.
extension Dictionary {
    func merged(with other: Dictionary) -> Dictionary {
        return merging(other) { _, new in new }
    }
}
