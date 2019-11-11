//
//  MissingReference.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 06/11/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A wrapper for missing reference object.
public struct MissingReference<T: Missable>: Codable {
    /// A decoded or missed value.
    public let value: T
    /// True if the value was missed.
    public let isMissed: Bool
    /// A decoding error instead of missing reference case.
    public let decodingError: Error?
    /// An enrichind activity error instead of object value.
    public let enrichingActivityError: EnrichingActivityError?
    
    init(_ value: T) {
        self.value = value
        isMissed = false
        enrichingActivityError = nil
        decodingError = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            value = try container.decode(T.self)
            isMissed = false
            enrichingActivityError = nil
            decodingError = nil
        } catch {
            value = T.missed()
            
            if let enrichingActivityError = try? container.decode(EnrichingActivityError.self) {
                self.enrichingActivityError = enrichingActivityError
                
                // The reference is missing.
                if enrichingActivityError.isReferenceNotFound {
                    isMissed = true
                    decodingError = nil
                    return
                }
            } else {
                enrichingActivityError = nil
            }
            
            isMissed = false
            decodingError = error
            
            // Show the decoding error that wasn't related to the missing reference.
            if Client.keepBadDecodedObjectsAsMissed {
                print("⚠️ Decoding was failed for type: \(T.self)", error)
                
                if let enrichingActivityError = self.enrichingActivityError {
                    print("⚠️", enrichingActivityError)
                }
            } else {
                throw error
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    /// The default missed reference value.
    public static func missed() -> MissingReference<T> {
        return MissingReference(T.missed())
    }
}

/// Missable is using to wrap objects with enrichment, where they was deleted and dependencies lost the link.
public protocol Missable: Codable {
    
    /// Check if the object is a missing reference.
    var isMissedReference: Bool { get }
    
    /// A placeholder for a missed object will be use in 2 cases:
    /// 1. A decoding error because a missing reference.
    /// 2. Any decoding error if `Client.keepBadDecodedObjectsAsMissed` is enabled.
    static func missed() -> Self
}
