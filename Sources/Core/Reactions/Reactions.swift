//
//  Reactions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public struct Reactions<T: ReactionExtraDataProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case reactions = "results"
    }
    
    private enum ActivityCodingKeys: String, CodingKey {
        case activity
    }
    
    public let reactions: [Reaction<T>]
    public var activity: Activity?
    private var activityContainer: KeyedDecodingContainer<Reactions<T>.ActivityCodingKeys>?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reactions = try container.decode([Reaction<T>].self, forKey: .reactions)
        
        let activityContainer = try decoder.container(keyedBy: ActivityCodingKeys.self)
        activity = try activityContainer.decodeIfPresent(Activity.self, forKey: .activity)
        self.activityContainer = activityContainer
    }
    
    public func activity<A: ActivityProtocol>(typeOf type: A.Type) -> A? {
        guard let activityContainer = activityContainer else {
            return nil
        }
        
        do {
            return try activityContainer.decodeIfPresent(type, forKey: .activity)
        } catch {
            return nil
        }
    }
}
