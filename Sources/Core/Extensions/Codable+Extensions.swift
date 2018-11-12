//
//  Codable+Extensions.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 12/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    /// A custom decoding for the custom ISO8601 date.
    public static let stream = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        var string: String = try container.decode(String.self)
        
        if let date = DateFormatter.stream.date(from: string) {
            return date
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension JSONEncoder.DateEncodingStrategy {
    /// A custom encoding for the custom ISO8601 date.
    public static let stream = custom { date, encoder throws in
        var container = encoder.singleValueContainer()
        try container.encode(DateFormatter.stream.string(from: date))
    }
}

// MARK: - Date Formatter Helpers

extension DateFormatter {
    fileprivate static let stream: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return formatter
    }()
}
