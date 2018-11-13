//
//  ExampleActivity.swift
//  GetStreamExample
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Alexey Bukhtin. All rights reserved.
//

import Foundation
import GetStream

final class Activity: GetStream.Activity {
    private enum CodingKeys: String, CodingKey {
        case tweet
    }
    
    var tweet: String?
    
    init(actor: String, verb: String, object: String, foreignId: String? = nil, time: Date? = nil) {
        super.init(actor: actor, verb: verb, object: object, foreignId: foreignId)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tweet = try container.decodeIfPresent(String.self, forKey: .tweet)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(tweet, forKey: .tweet)
        try super.encode(to: encoder)
    }
    
    override var description: String {
        return super.description.appending(" tweet: \(tweet ?? "<no value>")")
    }
}
