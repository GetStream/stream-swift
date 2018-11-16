//
//  ActivityEndpoint.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 16/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum ActivityEndpoint {
    case getByIds(_ ids: [UUID])
    case get(foreignIds: [String], times: [Date])
    case update(_ activities: ActivitiesContainer)
}

extension ActivityEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }

    var path: String {
        return "activities/"
    }
    
    var method: Moya.Method {
        switch self {
        case .getByIds:
            return .get
        case .get:
            return .get
        case .update:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getByIds(let ids):
            let ids = ids.map { $0.uuidString.lowercased() }.joined(separator: ",")
            return .requestParameters(parameters: ["ids" : ids], encoding: URLEncoding.default)
            
        case let .get(foreignIds: foreignIds, times: times):
            let foreignIds = foreignIds.joined(separator: ",")
            let times = times.map { DateFormatter.stream.string(from: $0) }.joined(separator: ",")
            return .requestParameters(parameters: ["foreign_ids": foreignIds, "timestamps": times], encoding: URLEncoding.default)
            
        case .update(let activities):
            return .requestCustomJSONEncodable(activities, encoder: .stream)
        }
    }
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleData: Data {
        return Data()
    }
}

// MARK: - Activities Container

open class ActivitiesContainer: Encodable {
    typealias ActivityType = Activity
    
    private enum CodingKey: String, Swift.CodingKey {
        case activities
    }
    
    var activities: [ActivityType] = []
    
    init(_ activities: [ActivityType]) {
        self.activities = activities
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(activities, forKey: .activities)
    }
}
