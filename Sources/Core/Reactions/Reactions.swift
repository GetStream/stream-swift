//
//  Reactions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public enum ReactionsError: Error {
    case reactionsHaveNoActivity
    case enrichingActivityError(_ error: EnrichingActivityError)
}

public struct Reactions<T: ReactionExtraDataProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case reactions = "results"
    }
    
    private enum ActivityCodingKeys: String, CodingKey {
        case activity
    }
    
    public let reactions: [Reaction<T>]
    private var activityContainer: KeyedDecodingContainer<Reactions<T>.ActivityCodingKeys>?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reactions = try container.decode([Reaction<T>].self, forKey: .reactions)
        activityContainer = try decoder.container(keyedBy: ActivityCodingKeys.self)
    }
    
    /// Get an enriched activity for reactions by activityId.
    ///
    public func activity<A: ActivityProtocol>(typeOf type: A.Type) throws -> A {
        guard let activityContainer = activityContainer else {
            throw ReactionsError.reactionsHaveNoActivity
        }
        
        do {
            return try activityContainer.decode(type, forKey: .activity)
        } catch {
            if let container = try? activityContainer.nestedContainer(keyedBy: Activity.CodingKeys.self, forKey: .activity) {
                if let actor = try? container.decode(EnrichingActivityError.self, forKey: .actor) {
                    throw ReactionsError.enrichingActivityError(actor)
                }
                
                if let object = try? container.decode(EnrichingActivityError.self, forKey: .object) {
                    throw ReactionsError.enrichingActivityError(object)
                }
                
                if let target = try? container.decode(EnrichingActivityError.self, forKey: .target) {
                    throw ReactionsError.enrichingActivityError(target)
                }
            }
            
            throw error
        }
    }
}
