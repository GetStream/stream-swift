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
    case getByIds(_ enrich: Bool, _ activitiesIds: [String])
    case get(_ enrich: Bool, foreignIds: [String], times: [Date])
    case update(_ activities: [T])
    case updateActivityById(setProperties: Properties?, unsetPropertiesNames: [String]?, activityId: String)
    case updateActivity(setProperties: Properties?, unsetPropertiesNames: [String]?, foreignId: String, time: Date)
}

extension ActivityEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case .getByIds(let enrich, _), .get(let enrich, _, _):
            return "\(enrich ? "enrich/" : "")activities/"
        case .update:
            return "activities/"
        case .updateActivityById, .updateActivity:
            return "activity/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getByIds, .get:
            return .get
            
        case .update, .updateActivityById, .updateActivity:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getByIds(_, let ids):
            let ids = ids.map { $0 }.joined(separator: ",")
            return .requestParameters(parameters: ["ids" : ids], encoding: URLEncoding.default)
            
        case let .get(_, foreignIds: foreignIds, times: times):
            return .requestParameters(parameters: idParameters(with: foreignIds, times: times), encoding: URLEncoding.default)
            
        case .update(let activities):
            return .requestCustomJSONEncodable(["activities": activities], encoder: JSONEncoder.default)
            
        case let .updateActivityById(setProperties, unsetPropertiesNames, activityId):
            let parameters: [String: Any] = ["id": activityId]
                .merged(with: setUnsetParameters(setProperties: setProperties, unsetPropertiesNames: unsetPropertiesNames))
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case let .updateActivity(setProperties, unsetPropertiesNames, foreignId, time):
            let parameters: [String: Any] = ["foreign_id": foreignId, "time": time.stream]
                .merged(with: setUnsetParameters(setProperties: setProperties, unsetPropertiesNames: unsetPropertiesNames))
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var sampleJSON: String {
        switch self {
        case let .getByIds(enrich, activitiesIds):
            let actorJSON = enrich
                ? "{\"id\":\"eric\",\"data\":{\"name\":\"Eric\"},\"updated_at\":\"2019-04-15T17:55:53.425\",\"created_at\":\"2019-04-15T17:55:53.425\"}"
                : "\"eric\""
            
            if activitiesIds.count == 2 {
                return """
                {"results":[
                {"actor":\(actorJSON),
                "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
                "id":"\(activitiesIds[0])",
                "object":"Hello world 3",
                "origin":null,
                "target":"",
                "time":"2018-11-14T15:54:45.268000",
                "to":["timeline:jessica"],
                "verb":"tweet"},
                {"actor":\(actorJSON),
                "foreign_id":"1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6",
                "id":"\(activitiesIds[1])",
                "object":"Hello world 2",
                "origin":null,
                "target":"",
                "time":"2018-11-14T11:00:32.282000",
                "verb":"tweet"}],
                "next":"",
                "duration":"15.73ms"}
                """
            }
        case let .get(_, foreignIds, times):
            if foreignIds.count == 2 {
                return """
                {"results":[
                {"actor":"eric",
                "foreign_id":"\(foreignIds[0])",
                "id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
                "object":"Hello world 3",
                "origin":null,
                "target":"",
                "time":"\(times[0].stream)",
                "to":["timeline:jessica"],
                "verb":"tweet"},
                {"actor":"eric",
                "foreign_id":"\(foreignIds[1])",
                "id":"1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6",
                "object":"Hello world 2",
                "origin":null,
                "target":"",
                "time":"\(times[1].stream)",
                "verb":"tweet"}],
                "next":"",
                "duration":"15.73ms"}
                """
            }
        case .update:
            return "{}"
        case let .updateActivityById(setProperties, unsetPropertiesNames, activityId):
            if let setProperties = setProperties as? [String: String],
                let unsetPropertiesNames = unsetPropertiesNames,
                unsetPropertiesNames.contains("image") {
                return """
                {"actor":"eric",
                "foreign_id":"",
                "id":"\(activityId)",
                "object":"\(setProperties["object"]!)",
                "origin":null,
                "target":"",
                "time":"2018-11-14T15:54:45.268000",
                "to":["timeline:jessica"],
                "verb":"tweet"}
                """
            }
        case let .updateActivity(setProperties, unsetPropertiesNames, foreignId, time):
            if let setProperties = setProperties as? [String: String],
                let unsetPropertiesNames = unsetPropertiesNames,
                unsetPropertiesNames.contains("image") {
                return """
                {"actor":"eric",
                "foreign_id":"\(foreignId)",
                "id":"1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6",
                "object":"\(setProperties["object"]!)",
                "origin":null,
                "target":"",
                "time":"\(time.stream)",
                "to":["timeline:jessica"],
                "verb":"tweet"}
                """
            }
        }
        
        return ""
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
