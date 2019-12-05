//
//  FeedEndpoint.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 07/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

// MARK: - Feed Activity Endpoint

enum FeedActivityEndpoint<T: ActivityProtocol> {
    case add(_ activity: T, feedId: FeedId)
}

extension FeedActivityEndpoint: StreamTargetType {
    var path: String {
        switch self {
        case .add(_, let feedId):
            return "feed/\(feedId.togetherWithSlash)/"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .add(let activity, feedId: _):
            return .requestCustomJSONEncodable(activity, encoder: JSONEncoder.default)
        }
    }
    
    var sampleJSON: String {
        switch self {
        case .add(let activity, feedId: _):
            if (activity.actor as? String) == ClientError.jsonInvalid("[]").localizedDescription {
                return "[]"
            } else if (activity.actor as? String) == ClientError.network("Failed to map data to JSON.", nil).localizedDescription {
                return "{"
            } else if (activity.actor as? String) == ClientError.server(.init(json: ["exception": 0])).localizedDescription {
                return "{\"exception\": 0}"
            }
            
            if activity.actor is String, activity.object is String {
                return """
                {"actor":"\((activity.actor as! Enrichable).referenceId)",
                "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
                "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
                "object":"\((activity.object as! Enrichable).referenceId)",
                "origin":null,
                "target":"",
                "time":"2018-11-14T15:54:45.268000",
                "to":["timeline:jessica"],
                "verb":"\(activity.verb)"}
                """
            }
            
            return """
            {"actor":"SU:eric",
            "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
            "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
            "object":"SO:burger",
            "origin":null,
            "target":"",
            "time":"2018-11-14T15:54:45.268000",
            "to":["timeline:jessica"],
            "verb":"\(activity.verb)"}
            """
        }
    }
}

// MARK: - Feed Endpoint

enum FeedEndpoint {
    case get(_ feedId: FeedId,
        _ enrich: Bool,
        _ pagination: Pagination,
        _ ranking: String,
        _ markOption: FeedMarkOption,
        _ reactionsOptions: FeedReactionsOptions)
    
    case deleteById(_ id: String, feedId: FeedId)
    case deleteByForeignId(_ foreignId: String, feedId: FeedId)
    case follow(_ feedId: FeedId, target: FeedId, activityCopyLimit: Int)
    case unfollow(_ feedId: FeedId, target: FeedId, keepHistory: Bool)
    case followers(_ feedId: FeedId, offset: Int, limit: Int)
    case following(_ feedId: FeedId, filter: FeedIds, offset: Int, limit: Int)
}

extension FeedEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case let .get(feedId, enrich, _, _, _, _):
            return "\(enrich ? "enrich/" : "")feed/\(feedId.togetherWithSlash)/"
            
        case let .deleteById(activityId, feedId):
            return "feed/\(feedId.togetherWithSlash)/\(activityId)/"
            
        case let .deleteByForeignId(foreignId, feedId):
            return "feed/\(feedId.togetherWithSlash)/\(foreignId)/"
            
        case let .follow(feedId, _, _):
            return "feed/\(feedId.togetherWithSlash)/follows/"
            
        case let .unfollow(feedId, target, _):
            return "feed/\(feedId.togetherWithSlash)/follows/\(target.description)/"
            
        case .followers(let feedId, _, _):
            return "feed/\(feedId.togetherWithSlash)/followers/"
            
        case .following(let feedId, _, _, _):
            return "feed/\(feedId.togetherWithSlash)/follows/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .get, .followers, .following:
            return .get
        case .follow:
            return .post
        case .deleteById, .deleteByForeignId, .unfollow:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case let .get(_, _, pagination, ranking, markOption, reactionsOptions):
            if case .none = pagination, ranking.isEmpty, case .none = markOption, reactionsOptions == [] {
                return .requestPlain
            }
            
            var parameters = pagination.parameters.merged(with: markOption.parameters)
            
            if !ranking.isEmpty {
                parameters["ranking"] = ranking
            }
            
            if reactionsOptions.contains(.own) {
                parameters["withOwnReactions"] = true
            }
            
            if reactionsOptions.contains(.ownChildren) {
                parameters["withOwnChildren"] = true
            }

            if reactionsOptions.contains(.latest) {
                parameters["withRecentReactions"] = true
            }
            
            if reactionsOptions.contains(.counts) {
                parameters["withReactionCounts"] = true
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .deleteById:
            return .requestPlain
            
        case .deleteByForeignId:
            return .requestParameters(parameters: ["foreign_id": 1], encoding: URLEncoding.default)
            
        case let .follow(_, target, activityCopyLimit):
            return .requestParameters(parameters: ["target": target.description,
                                                   "activity_copy_limit": activityCopyLimit], encoding: JSONEncoding.default)
            
        case .unfollow(_, _, let keepHistory):
            if keepHistory {
                return .requestParameters(parameters: ["keep_history": "1"], encoding: URLEncoding.default)
            }
            
            return .requestPlain
            
        case let .followers(_, offset, limit):
            return .requestParameters(parameters: ["limit": limit, "offset": offset], encoding: URLEncoding.default)
            
        case let .following(_, filter, offset, limit):
            var parameters: [String: Any] = ["limit": limit, "offset": offset]
            
            if !filter.isEmpty {
                parameters["filter"] = filter.value
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var sampleJSON: String {
        switch self {
        case let .get(feedId, _, pagination, _, _, _):
            if feedId.feedSlug == "bad" {
                return ""
            } else if feedId.feedSlug == "aggregated" {
                return """
                {"results":[{"activities":[{"actor":"Me","foreign_id":"","id":"2e7ef88c-0505-11e9-94fe-0a9265761cda","nr_of_penalty":2,"nr_of_score":3,"object":"Message","origin":null,"target":"","time":"2018-12-21T09:45:42.455925","type":"football","verb":"verb"},{"actor":"Me","foreign_id":"","id":"2e6df127-0505-11e9-aafe-1231d51167b4","nr_of_blocked":1,"nr_of_served":1,"object":"Message","origin":null,"target":"","time":"2018-12-21T09:45:42.344324","type":"volley","verb":"verb"}],"activity_count":2,"actor_count":1,"created_at":"2018-12-21T09:45:42.348570","group":"verb_2018-12-21","id":"2e7ef88c-0505-11e9-94fe-0a9265761cda","updated_at":"2018-12-21T09:45:42.461997","verb":"verb"},{"activities":[{"actor":"Me","foreign_id":"","id":"a79f4090-ddfa-11e8-9c6f-1231d51167b4","nr_of_penalty":2,"nr_of_score":3,"object":"Message","origin":null,"target":"","time":"2018-11-01T17:22:05.859445","type":"football","verb":"verb"},{"actor":"Me","foreign_id":"","id":"a78f74a5-ddfa-11e8-9c6c-1231d51167b4","nr_of_blocked":1,"nr_of_served":1,"object":"Message","origin":null,"target":"","time":"2018-11-01T17:22:05.755921","type":"volley","verb":"verb"}],"activity_count":2,"actor_count":1,"created_at":"2018-11-01T17:22:05.760803","group":"verb_2018-11-01","id":"a79f4090-ddfa-11e8-9c6f-1231d51167b4","updated_at":"2018-11-01T17:22:05.864280","verb":"verb"}],"next":"","duration":"18.25ms"}
                """
            } else if feedId.feedSlug == "notifications" {
                return """
                {"results":[{"activities":[{"actor":"test","foreign_id":"","id":"79d41147-d2f2-11e8-bf25-1231d51167b4","object":"test","origin":null,"target":"","time":"2018-10-18T16:25:50.265991","verb":"test"},{"actor":"test","foreign_id":"","id":"796e2993-d2f2-11e8-a318-0a9265761cda","object":"test","origin":null,"target":"","time":"2018-10-18T16:25:49.598146","verb":"test"},{"actor":"test","foreign_id":"","id":"22c058de-d2f2-11e8-a18a-0a9265761cda","object":"test","origin":null,"target":"","time":"2018-10-18T16:23:24.174973","verb":"test"},{"actor":"test","foreign_id":"","id":"225c7acc-d2f2-11e8-a189-0a9265761cda","object":"test","origin":null,"target":"","time":"2018-10-18T16:23:23.520482","verb":"test"},{"actor":"test","foreign_id":"","id":"352686cf-d2f1-11e8-b9c2-1231d51167b4","object":"test","origin":null,"target":"","time":"2018-10-18T16:16:45.546875","verb":"test"},{"actor":"test","foreign_id":"","id":"34c3afcc-d2f1-11e8-b9bc-1231d51167b4","object":"test","origin":null,"target":"","time":"2018-10-18T16:16:44.899118","verb":"test"}],"activity_count":6,"actor_count":1,"created_at":"2018-10-18T16:16:44.904186","group":"test_2018-10-18","id":"79d41147-d2f2-11e8-bf25-1231d51167b4.test_2018-10-18","is_read":false,"is_seen":true,"updated_at":"2018-10-18T16:25:50.272399","verb":"test"}],"next":"","duration":"9.98ms","unseen":0,"unread":1}
                """
                
            } else if feedId.feedSlug == "enrich" {
                return """
                {"results":[{"actor":{"created_at":"2018-12-20T15:41:25.181144Z","updated_at":"2018-12-20T15:41:25.181144Z","id":"eric","data":{"name":"Eric"}},"foreign_id":"","id":"ce918867-0520-11e9-a11e-0a286b200b2e","object":{"id":"burger","collection":"food","foreign_id":"food:burger","data":{"name":"Burger"},"created_at":"2018-12-20T16:07:14.726306Z","updated_at":"2018-12-20T16:07:14.726306Z"},"origin":null,"target":"","time":"2018-12-21T13:03:27.424727","verb":"eat"}],"next":"","duration":"15.71ms"}
                """
                
            } else if case .limit(let limit) = pagination, limit == 1 {
                return """
                {"results":[{"actor":"eric","foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D","id":"9b5b3540-e825-11e8-8080-800016ff21e4","object":"Hello world 3","origin":null,"target":"","time":"2018-11-14T15:54:45.268000","to":["timeline:jessica"],"verb":"tweet"}],"next":"","duration":"2.31ms"}
                """
            } else {
                return """
                {"results":[{"actor":"eric","foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D","id":"9b5b3540-e825-11e8-8080-800016ff21e4","object":"Hello world 3","origin":null,"target":"","time":"2018-11-14T15:54:45.268000","to":["timeline:jessica"],"verb":"tweet"},{"actor":"eric","foreign_id":"1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6","id":"815b4fa0-e7fc-11e8-8080-80007911093a","object":"Hello world 2","origin":null,"target":"","time":"2018-11-14T11:00:32.282000","verb":"tweet"},{"actor":"eric","foreign_id":"FFBE449A-54B1-4701-A1E1-79E5DD5AF4BD","id":"2737dc60-e7fb-11e8-8080-80014193e462","object":"Hello world 1","origin":null,"target":"","time":"2018-11-14T10:50:51.558000","verb":"tweet"}],"next":"","duration":"15.73ms"}
                """
            }
            
        case .deleteById(let activityId, _):
            return "{\"removed\":\"\(activityId)\"}"
            
        case .deleteByForeignId(let foreignId, _):
            return "{\"removed\":\"\(foreignId)\"}"
            
        case .follow(_, let target, _):
            if target.description == "s2:u2" {
                return "{}"
            }
            
        case let .unfollow(_, target, keepHistory):
            return keepHistory ? "[]" : (target.description == "s2:u2" ? "{}" : "")
            
        case .followers(let feedId, _, _):
            return """
            {"results": [
            {"feed_id": "\(feedId.togetherWithColon)",
            "target_id": "s2:u2",
            "created_at": "2018-11-14T15:54:45.268000Z"}
            ]}
            """
            
        case .following(let feedId, _, _, _):
            return """
            {"results": [
            {"feed_id": "\(feedId.togetherWithColon)",
            "target_id": "s2:u2",
            "created_at": "2018-11-14T15:54:45.268000Z"}
            ]}
            """
        }
        
        return ""
    }
}

// MARK: - Feed Mark Option

public enum FeedMarkOption {
    case none
    case seenAll
    case seen(_ groupIds: [String])
    case readAll
    case read(_ groupIds: [String])
    
    /// Parameters for a request.
    fileprivate var parameters: [String: Any] {
        switch self {
        case .none:
            return [:]
        case .seenAll:
            return ["mark_seen": true]
        case .seen:
            return ["mark_seen": groupIdsValue() ]
        case .readAll:
            return ["mark_read": true]
        case .read:
            return ["mark_read": groupIdsValue() ]
        }
    }
    
    private func groupIdsValue() -> String {
        switch self {
        case .seen(let groupIds), .read(let groupIds):
            return groupIds.map { $0.description }.joined(separator: ",")
        default:
            return ""
        }
    }
}

// MARK: - Reactions Option

/// A feed reaction options to include reaction for activities.
/// - Available options:
///     - `includeOwn`: include reactions added by current user to all activities.
///     - `includeOwnChildren`: include reactions added by current user to all reactions.
///     - `includeRecent`: include recent reactions to activities.
///     - `includeCounts`: include reaction counts to activities.
public struct FeedReactionsOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Include reactions added by current user to all activities.
    public static let own = FeedReactionsOptions(rawValue: 1 << 0)
    /// Include reactions added by current user to all reactions.
    public static let ownChildren = FeedReactionsOptions(rawValue: 1 << 1)
    /// Include recent reactions to activities.
    public static let latest = FeedReactionsOptions(rawValue: 1 << 2)
    /// Include reaction counts to activities.
    public static let counts = FeedReactionsOptions(rawValue: 1 << 3)
    /// Include all reactions options to activities.
    public static let all: FeedReactionsOptions = [.own, .ownChildren, .latest, .counts]
}
