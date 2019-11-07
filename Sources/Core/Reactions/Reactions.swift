//
//  Reactions.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 14/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

/// A reactions error.
public enum ReactionsError: LocalizedError, CustomStringConvertible {
    case reactionsHaveNoActivity
    case enrichingActivityError(_ error: EnrichingActivityError)
    
    public var description: String {
        switch self {
        case .reactionsHaveNoActivity:
            return "Reactions have not an activity"
        case .enrichingActivityError(let error):
            return "Enriching activity error: \(error.localizedDescription)"
        }
    }
    
    public var localizedDescription: String {
        return description
    }
    
    public var errorDescription: String? {
        return description
    }
}

/// A reactions type.
public struct Reactions<T: ReactionExtraDataProtocol, U: UserProtocol>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case reactions = "results"
        case next
    }
    
    private enum ActivityCodingKeys: String, CodingKey {
        case activity
    }
    
    /// A list of reactions.
    public let reactions: [Reaction<T, U>]
    /// A pagination option for the next page.
    public private(set) var next: Pagination?
    private var activityContainer: KeyedDecodingContainer<Reactions<T, U>.ActivityCodingKeys>?
    
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
    ///
    /// - Parameter type: the type of `ActivityProtocol` of reactions.
    /// - Returns: the activity of reactions.
    public func activity<A: ActivityProtocol>(typeOf type: A.Type) throws -> A {
        guard let activityContainer = activityContainer else {
            throw ReactionsError.reactionsHaveNoActivity
        }
        
        return try activityContainer.decode(type, forKey: .activity)
    }
}
