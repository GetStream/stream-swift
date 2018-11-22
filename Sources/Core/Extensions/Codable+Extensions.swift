//
//  Codable+Extensions.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

// MARK: - JSONDecoder

extension JSONDecoder {
    public struct Stream {
        public static let `default`: JSONDecoder = decoder { $0.streamDate }
        public static let iso8601: JSONDecoder = decoder { DateFormatter.Stream.iso8601Date(from: $0) }
        
        private static func decoder(dateParser: @escaping (_ dateString: String) -> Date?) -> JSONDecoder {
            let decoder = JSONDecoder()
            
            /// A custom decoding for a date.
            decoder.dateDecodingStrategy = .custom { decoder throws -> Date in
                let container = try decoder.singleValueContainer()
                let string: String = try container.decode(String.self)
                
                if let date = dateParser(string) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
            }
            
            return decoder
        }
    }
}

// MARK: - JSONEncoder

extension JSONEncoder {
    public struct Stream {
        public static let `default`: JSONEncoder = {
            let encoder = JSONEncoder()
            
            /// A custom encoding for the custom ISO8601 date.
            encoder.dateEncodingStrategy = .custom { date, encoder throws in
                var container = encoder.singleValueContainer()
                try container.encode(DateFormatter.Stream.default.string(from: date))
            }
            
            return encoder
        }()
    }
}

// MARK: - JSON Encoder Helper

struct AnyEncodable: Encodable {
    private let encodable: Encodable
    
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

// MARK: - Date Formatter Helper

extension DateFormatter {
    public struct Stream {
        public static let `default`: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            
            return formatter
        }()
        
        public static func iso8601Date(from string: String) -> Date? {
            if #available(iOS 11, macOS 10.13, *) {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter.date(from: string)
            }
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            return formatter.date(from: string)
        }
    }
}

extension Date {
    public var stream: String {
        return DateFormatter.Stream.default.string(from: self)
    }
}

extension String {
    public var streamDate: Date? {
        return DateFormatter.Stream.default.date(from: self)
    }
}
