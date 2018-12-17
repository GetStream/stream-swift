//
//  ReactionEndpoint.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 11/12/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import Foundation
import Moya

enum ReactionEndpoint {
    case add(_ activityId: UUID,
        _ parentReactionId: UUID?,
        _ kind: ReactionKind,
        _ data: ReactionExtraDataProtocol,
        _ feedIds: [FeedId])
    
    case get(_ reactionId: UUID)
    case delete(_ reactionId: UUID)
    case update(_ reactionId: UUID, _ data: ReactionExtraDataProtocol, _ feedIds: [FeedId])
    case reactionsByActivityId(_ activityId: UUID, _ kind: ReactionKind?, _ pagination: Pagination, _ withActivityData: Bool)
    case reactionsByReactionId(_ reactionId: UUID, _ kind: ReactionKind?, _ pagination: Pagination)
    case reactionsByUserId(_ userId: String, _ kind: ReactionKind?, _ pagination: Pagination)
}

extension ReactionEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case .add:
            return "reaction/"
        case .get(let reactionId), .delete(let reactionId), .update(let reactionId, _, _):
            return "reaction/\(reactionId.lowercasedString)/"
        case let .reactionsByActivityId(activityId, kind, _, _):
            return "reaction/activity_id/\(activityId.lowercasedString)/\((kind == nil ? "" : "\(kind ?? "")/"))"
        case let .reactionsByReactionId(reactionId, kind, _):
            return "reaction/reaction_id/\(reactionId.lowercasedString)/\((kind == nil ? "" : "\(kind ?? "")/"))"
        case let .reactionsByUserId(userId, kind, _):
            return "reaction/user_id/\(userId)/\((kind == nil ? "" : "\(kind ?? "")/"))"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .add:
            return .post
        case .get, .reactionsByActivityId, .reactionsByReactionId, .reactionsByUserId:
            return .get
        case .delete:
            return .delete
        case .update:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case let .add(activityId, parentReactionId, kind, data, feedIds):
            return .requestJSONEncodable(ReactionAddParameters(activityId: activityId.lowercasedString,
                                                               parentReactionId: parentReactionId?.lowercasedString,
                                                               kind: kind,
                                                               data: AnyEncodable(data),
                                                               feedIds: feedIds))
            
        case .get, .delete:
            return .requestPlain
            
        case let .update(_, data, feedIds):
            return .requestJSONEncodable(ReactionAddParameters(data: AnyEncodable(data), feedIds: feedIds))
            
        case .reactionsByActivityId(_, _, let pagination, _),
             .reactionsByReactionId(_, _, let pagination),
             .reactionsByUserId(_, _, let pagination):
            var parameters: JSON = pagination.parameters
            
            if case .reactionsByActivityId(_, _, _, let withActivityData) = self {
                parameters["with_activity_data"] = withActivityData
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
}

extension ReactionEndpoint {
    private struct ReactionAddParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case kind
            case activityId = "activity_id"
            case parentReactionId = "parent"
            case data
            case feedIds = "target_feeds"
        }
        
        var activityId: String?
        var parentReactionId: String?
        var kind: ReactionKind?
        let data: AnyEncodable?
        let feedIds: [FeedId]?
        
        init(activityId: String? = nil,
             parentReactionId: String? = nil,
             kind: ReactionKind? = nil,
             data: AnyEncodable,
             feedIds: [FeedId]) {
            self.activityId = activityId
            self.parentReactionId = parentReactionId
            self.kind = kind
            self.data = data.encodable is ReactionNoExtraData ? nil : data
            self.feedIds = feedIds.isEmpty ? nil : feedIds
        }
    }
}
