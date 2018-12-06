//
//  ChannelName.swift
//  Faye
//
//  Created by Alexey Bukhtin on 28/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias ChannelName = String

extension ChannelName {
    
    /// Check if the channel name is a wildcard.
    private var isWildcard: Bool {
        guard let last = last else {
            return false
        }
        
        return last == "*"
    }
    
    /// Check if the channel name is a wildcard for multiple segments.
    private var isMultipleSegmentsWildcard: Bool {
        guard isWildcard else {
            return false
        }
        
        return self[utf8.index(before: endIndex)] == "*"
    }
    
    /// Extract a base name for the wildcard without "`*`".
    private var wildcardBase: ChannelName? {
        guard let index = firstIndex(where: { $0 == "*" }) else {
            return nil
        }
        
        return ChannelName(self[..<index])
    }
    
    /// Check if a given channel name matched with the current name.
    ///
    /// - Examples:
    ///     - `foo + /foo -> true`
    ///     - `foo/bar + /foo -> false`
    ///     - `foo/* + /foo -> true`
    ///     - `foo/* + /foo/bar -> true`
    ///     - `foo/* + /foo/bar/baz -> false`
    ///     - `foo/** + /foo/bar/baz -> true`
    ///
    /// - Parameters:
    ///     - channelName: an another channel name
    func match(with channelName: ChannelName) -> Bool {
        if self == channelName {
            return true
        }
        
        if channelName.isWildcard || channelName.count == 0 {
            return false
        }
        
        guard isWildcard else {
            return self == channelName
        }
        
        guard let wildcardBase = self.wildcardBase, channelName.prefix(wildcardBase.count) == wildcardBase else {
            return false
        }
        
        let index = channelName.index(channelName.startIndex, offsetBy: wildcardBase.count)
        let segment = String(channelName[index...]).slashTrimmed()
        let hasMultipleSegments = segment.contains("/")
        
        return !hasMultipleSegments || isMultipleSegmentsWildcard
    }
    
    /// Create a channel name with the current wildcard and a given segment.
    /// Return self if the current channel name is not a wildcard.
    ///
    /// - Examples:
    ///     - (segment: `bar`) `foo/* --> foo/bar`
    ///     - (segment: `bar/baz`) `foo/** --> foo/bar/baz`
    func wildcard(with segment: ChannelName?) throws -> ChannelName {
        guard isWildcard else {
            return self
        }
        
        let wildcardBase = self.wildcardBase ?? self
        
        guard let segment = segment else {
            throw Error.wildcardWithoutSegment(self)
        }
        
        let hasMultipleSegments = segment.contains("/")
        
        guard isMultipleSegmentsWildcard || !hasMultipleSegments else {
            throw Error.wildcardIsNotMatchedWithSegment(segment)
        }
        
        return wildcardBase.appending("/").appending(segment.slashTrimmed())
    }
}

// MARK: - Error

extension ChannelName {
    public enum Error: Swift.Error {
        case wildcardWithoutSegment(_ wildcard: ChannelName)
        case wildcardIsNotMatchedWithSegment(_ segment: ChannelName)
    }
}

// MARK: - Helper

extension String {
    /// Remove "`/`" char from the string.
    func slashTrimmed() -> String {
        return trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}
