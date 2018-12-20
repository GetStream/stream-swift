//
//  Sport.swift
//  GetStreamExample
//
//  Created by Alexey Bukhtin on 20/12/2018.
//  Copyright © 2018 Alexey Bukhtin. All rights reserved.
//

import Foundation
import GetStream

final class Sport: GetStream.Activity {
    private enum CodingKeys: String, CodingKey {
        case penalty = "nr_of_penalty"
        case score = "nr_of_score"
        case type
    }
    
    var penalty: Int?
    var score: Int?
    var type: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        penalty = try container.decodeIfPresent(Int.self, forKey: .penalty)
        score = try container.decodeIfPresent(Int.self, forKey: .score)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        try super.init(from: decoder)
    }
}
