//
//  FeedEndpoint.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 07/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum FeedEndpoint {
    case get(_ feedId: FeedId, pagination: Pagination, ranking: String, markOption: FeedMarkOption)
    case add(_ activity: ActivityProtocol, feedId: FeedId)
    case deleteById(_ id: UUID, feedId: FeedId)
    case deleteByForeignId(_ foreignId: String, feedId: FeedId)
    case follow(_ feedId: FeedId, target: FeedId, activityCopyLimit: Int)
    case unfollow(_ feedId: FeedId, target: FeedId, keepHistory: Bool)
    case followers(_ feedId: FeedId, offset: Int, limit: Int)
    case following(_ feedId: FeedId, filter: FeedIds, offset: Int, limit: Int)
}

extension FeedEndpoint: TargetType {
    var baseURL: URL {
        return BaseURL.placeholderURL
    }
    
    var path: String {
        switch self {
        case .get(let feedId, _, _, _), .add(_, let feedId):
            return "feed/\(feedId.togetherWithSlash)/"
            
        case let .deleteById(activityId, feedId):
            return "feed/\(feedId.togetherWithSlash)/\(activityId.lowercasedString)/"
            
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
            
        case .add, .follow:
            return .post
            
        case .deleteById, .deleteByForeignId, .unfollow:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case let .get(_, pagination, ranking, markOption):
            if case .none = pagination, ranking.isEmpty, case .none = markOption {
                return .requestPlain
            }
            
            var parameters = pagination.parameters.merged(with: markOption.parameters)
            
            if !ranking.isEmpty {
                parameters["ranking"] = ranking
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .add(let activity, feedId: _):
            return .requestCustomJSONEncodable(activity, encoder: JSONEncoder.Stream.default)
            
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
    
    var headers: [String : String]? {
        return Client.headers
    }
    
    var sampleData: Data {
        var json = ""
        
        switch self {
        case let .get(feedId, pagination: pagination, _, _):
            if feedId.feedSlug == "bad", feedId.userId == "json" {
                json = "{"
                
            } else if case .limit(let limit) = pagination, limit == 1 {
                json = """
                {"results":[
                {"actor":"eric",
                "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
                "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
                "object":"Hello world 3",
                "origin":null,
                "target":"",
                "time":"2018-11-14T15:54:45.268000",
                "to":["timeline:jessica"],
                "verb":"tweet"}],
                "next":"",
                "duration":"2.31ms"}
                """
            } else {
                json = """
                {"results":[
                {"actor":"eric",
                "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
                "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
                "object":"Hello world 3",
                "origin":null,
                "target":"",
                "time":"2018-11-14T15:54:45.268000",
                "to":["timeline:jessica"],
                "verb":"tweet"},
                {"actor":"eric",
                "foreign_id":"1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6",
                "id":"815b4fa0-e7fc-11e8-8080-80007911093a",
                "object":"Hello world 2",
                "origin":null,
                "target":"",
                "time":"2018-11-14T11:00:32.282000",
                "verb":"tweet"},
                {"actor":"eric",
                "foreign_id":"FFBE449A-54B1-4701-A1E1-79E5DD5AF4BD",
                "id":"2737dc60-e7fb-11e8-8080-80014193e462",
                "object":"Hello world 1",
                "origin":null,
                "target":"",
                "time":"2018-11-14T10:50:51.558000",
                "verb":"tweet"}],
                "next":"",
                "duration":"15.73ms"}
                """
            }
            
        case .add(let activity, feedId: _):
            if activity.actor == ClientError.jsonInvalid.localizedDescription {
                json = "[]"
                
            } else if activity.actor == ClientError.network("Failed to map data to JSON.").localizedDescription {
                json = "{"
                
            } else if activity.actor == ClientError.server(.init(json: ["exception": 0])).localizedDescription {
                json = "{\"exception\": 0}"
                
            } else {
                json = """
                {"actor":"\(activity.actor)",
                "foreign_id":"1E42DEB6-7C2F-4DA9-B6E6-0C6E5CC9815D",
                "id":"9b5b3540-e825-11e8-8080-800016ff21e4",
                "object":"\(activity.object)",
                "origin":null,
                "target":"\(activity.target ?? "")",
                "time":"2018-11-14T15:54:45.268000",
                "to":["timeline:jessica"],
                "verb":"\(activity.verb)"}
                """
            }
            
        case .deleteById(let activityId, _):
            json = "{\"removed\":\"\(activityId.lowercasedString)\"}"
            
        case .deleteByForeignId(let foreignId, _):
            json = "{\"removed\":\"\(foreignId)\"}"
            
        case .follow(_, let target, _):
            if target.description == "s2:u2" {
                json = "{}"
            }
            
        case let .unfollow(_, target, keepHistory):
            if target.description == "s2:u2" {
                json = "{}"
            }
            
            if keepHistory {
                json = "[]"
            }

        case .followers(let feedId, _, _):
            json = """
            {"results": [
            {"feed_id": "\(feedId.togetherWithColon)",
            "target_id": "s2:u2",
            "created_at": "2018-11-14T15:54:45.268000Z"}
            ]}
            """
            
        case .following(let feedId, _, _, _):
            json = """
            {"results": [
            {"feed_id": "\(feedId.togetherWithColon)",
            "target_id": "s2:u2",
            "created_at": "2018-11-14T15:54:45.268000Z"}
            ]}
            """
        }
        
        return json.data(using: .utf8)!
    }
}

// MARK: - Feed Mark Option

public enum FeedMarkOption {
    case none
    case seenAll
    case seen(_ feedIds: FeedIds)
    case readAll
    case read(_ feedIds: FeedIds)
    
    /// Parameters for a request.
    fileprivate var parameters: [String: Any] {
        switch self {
        case .none:
            return [:]
        case .seenAll:
            return ["mark_seen": true]
        case .seen(let feedIds):
            return ["mark_seen": feedIds.value ]
        case .readAll:
            return ["mark_read": true]
        case .read(let feedIds):
            return ["mark_read": feedIds.value ]
        }
    }
}
