//
//  ActivityEndpoint.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 16/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

/// Properties where keys are the target fields and the values are the values to be set.
///
/// - Note: It's possible to reference the target fields directly
///         or using the dotted notation `grandfather.father.child`, given that it respects the existing hierarchy.
public typealias Properties = [String: Encodable]

enum ActivityEndpoint<T: ActivityProtocol> {
    case getByIds(_ activitiesIds: [UUID])
    case get(foreignIds: [String], times: [Date])
    case update(_ activities: [T])
    case updateActivityById(setProperties: Properties?, unsetPropertiesNames: [String]?, activityId: UUID)
    case updateActivity(setProperties: Properties?, unsetPropertiesNames: [String]?, foreignId: String, time: Date)
}

extension ActivityEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
    var path: String {
        switch self {
        case .getByIds:
            return "activities/"
        case .get:
            return "activities/"
        case .update:
            return "activities/"
        case .updateActivityById:
            return "activity/"
        case .updateActivity:
            return "activity/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getByIds:
            return .get
        case .get:
            return .get
        case .update:
            return .post
        case .updateActivityById:
            return .post
        case .updateActivity:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getByIds(let ids):
            let ids = ids.map { $0.uuidString.lowercased() }.joined(separator: ",")
            return .requestParameters(parameters: ["ids" : ids], encoding: URLEncoding.default)
            
        case let .get(foreignIds: foreignIds, times: times):
            return .requestParameters(parameters: idParameters(with: foreignIds, times: times), encoding: URLEncoding.default)
            
        case .update(let activities):
            return .requestCustomJSONEncodable(["activities": activities], encoder: JSONEncoder.Stream.default)
            
        case let .updateActivityById(setProperties, unsetPropertiesNames, activityId):
            let parameters: [String: Any] = ["id": activityId.uuidString.lowercased()]
                .merged(with: setUnsetParameters(setProperties: setProperties, unsetPropertiesNames: unsetPropertiesNames))
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case let .updateActivity(setProperties, unsetPropertiesNames, foreignId, time):
            let parameters: [String: Any] = ["foreign_id": foreignId, "time": time.stream]
                .merged(with: setUnsetParameters(setProperties: setProperties, unsetPropertiesNames: unsetPropertiesNames))
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleData: Data {
        return Data()
    }
}

extension ActivityEndpoint {
    private func setUnsetParameters(setProperties properties: Properties?, unsetPropertiesNames names: [String]?) -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        if let properties = properties {
            parameters["set"] = properties
        }
        
        if let names = names {
            parameters["unset"] = names
        }
        
        return parameters
    }
    
    private func idParameters(with foreignIds: [String], times: [Date]) -> [String: Any] {
        let foreignIds = foreignIds.joined(separator: ",")
        let times = times.map { $0.stream }.joined(separator: ",")
        return ["foreign_ids": foreignIds, "timestamps": times]
    }
}
