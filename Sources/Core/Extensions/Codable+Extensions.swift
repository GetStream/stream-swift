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
    public static let stream: JSONDecoder = {
        let decoder = JSONDecoder()
        
        /// A custom decoding for the custom ISO8601 date.
        decoder.dateDecodingStrategy = .custom { decoder throws -> Date in
            let container = try decoder.singleValueContainer()
            var string: String = try container.decode(String.self)
            
            if let date = DateFormatter.stream.date(from: string) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        
        return decoder
    }()
}

// MARK: - JSONEncoder

extension JSONEncoder {
    public static let stream: JSONEncoder = {
        let encoder = JSONEncoder()
        
        /// A custom encoding for the custom ISO8601 date.
        encoder.dateEncodingStrategy = .custom { date, encoder throws in
            var container = encoder.singleValueContainer()
            try container.encode(DateFormatter.stream.string(from: date))
        }
        
        return encoder
    }()
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
    public static let stream: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return formatter
    }()
}

extension Date {
    public var stream: String {
        return DateFormatter.stream.string(from: self)
    }
}

extension String {
    public var streamDate: Date? {
        return DateFormatter.stream.date(from: self)
    }
}
