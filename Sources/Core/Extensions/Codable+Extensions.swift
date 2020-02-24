//
//  Codable+Extensions.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

// MARK: - JSONDecoder Stream

extension JSONDecoder {
    /// A default decoder.
    public static var `default`: JSONDecoder = stream
    
    /// A Stream decoder.
    public static let stream: JSONDecoder = {
        let decoder = JSONDecoder()
        
        /// A custom decoding for a date.
        decoder.dateDecodingStrategy = .custom { decoder throws -> Date in
            let container = try decoder.singleValueContainer()
            let string: String = try container.decode(String.self)
            
            if string.hasSuffix("Z") {
                if let date = DateFormatter.Stream.iso8601DateFormatter.date(from: string) {
                    return date
                }
            } else if let date = string.streamDate {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        
        return decoder
    }()
}

// MARK: - JSONEncoder Stream

extension JSONEncoder {
    /// A default encoder.
    public static var `default`: JSONEncoder = stream
    
    /// A Stream encoder.
    public static let stream: JSONEncoder = {
        let encoder = JSONEncoder()
        
        /// A custom encoding for the custom ISO8601 date.
        encoder.dateEncodingStrategy = .custom { date, encoder throws in
            var container = encoder.singleValueContainer()
            try container.encode(DateFormatter.Stream.default.string(from: date))
        }
        
        return encoder
    }()
}

// MARK: - JSON Encoder Helper

struct AnyEncodable: Encodable {
    let encodable: Encodable
    
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

// MARK: - Date Formatter Helper

extension DateFormatter {
    /// A Stream Client date formatter.
    public struct Stream {
        public static let `default`: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            
            return formatter
        }()
        
        public static let iso8601DateFormatter: ISO8601DateFormatter = {
            if #available(iOS 11.2, macOS 10.13, *) {
                let formatter = Foundation.ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            return formatter
        }()
    }
}

// MARK: - Date Stream

extension Date {
    /// Convert a date to the Stream Client date string.
    public var stream: String {
        return DateFormatter.Stream.default.string(from: self)
    }
}

// MARK: - String Date Stream

extension String {
    /// Convert a string to the Stream Client date.
    public var streamDate: Date? {
        return DateFormatter.Stream.default.date(from: self)
    }
}

// MARK: - ISO8601 Date Formatter

public protocol ISO8601DateFormatter {
    func date(from: String) -> Date?
}

@available(iOS 10.0, macOS 10.13, *)
extension Foundation.ISO8601DateFormatter: ISO8601DateFormatter {}
extension DateFormatter: ISO8601DateFormatter {}
