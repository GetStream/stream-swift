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

public struct Reactions<T: ReactionExtraDataProtocol, U: UserProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case reactions = "results"
        case next
    }
    
    private enum ActivityCodingKeys: String, CodingKey {
        case activity
    }
    
    public let reactions: [Reaction<T, U>]
    public private(set) var next: Pagination?
    private var activityContainer: KeyedDecodingContainer<Reactions<T, U>.ActivityCodingKeys>?
    
    public var activity: Activity? {
        return try? activity(typeOf: Activity.self)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reactions = try container.decode([Reaction<T, U>].self, forKey: .reactions)
        next = try container.decodeIfPresent(Pagination.self, forKey: .next)
        
        if let next = next, case .none = next {
            self.next = nil
        }
        
        activityContainer = try decoder.container(keyedBy: ActivityCodingKeys.self)
    }
    
    /// Get an activity for reactions that was requested by `activityId` and the `withActivityData` property.
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
