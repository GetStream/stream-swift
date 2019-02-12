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
    case add(_ activityId: String,
        _ parentReactionId: String?,
        _ kind: ReactionKind,
        _ data: ReactionExtraDataProtocol,
        _ feedIds: FeedIds)
    
    case get(_ reactionId: String)
    case delete(_ reactionId: String)
    case update(_ reactionId: String, _ data: ReactionExtraDataProtocol, _ feedIds: FeedIds)
    case reactionsByActivityId(_ activityId: String, _ kind: ReactionKind?, _ pagination: Pagination, _ withActivityData: Bool)
    case reactionsByReactionId(_ reactionId: String, _ kind: ReactionKind?, _ pagination: Pagination)
    case reactionsByUserId(_ userId: String, _ kind: ReactionKind?, _ pagination: Pagination)
}

extension ReactionEndpoint: StreamTargetType {
    
    var path: String {
        switch self {
        case .add:
            return "reaction/"
        case .get(let reactionId), .delete(let reactionId), .update(let reactionId, _, _):
            return "reaction/\(reactionId)/"
        case let .reactionsByActivityId(activityId, kind, _, _):
            return "reaction/activity_id/\(activityId)/\((kind == nil ? "" : "\(kind ?? "")/"))"
        case let .reactionsByReactionId(reactionId, kind, _):
            return "reaction/reaction_id/\(reactionId)/\((kind == nil ? "" : "\(kind ?? "")/"))"
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
            return .requestJSONEncodable(ReactionAddParameters(activityId: activityId,
                                                               parentReactionId: parentReactionId,
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
            
            parameters["withOwnChildren"] = 1
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var sampleJSON: String {
        switch self {
        case .add(_, _, let kind, _, _):
            return kind == "comment"
                ? """
            {"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hello!"},"parent":"","latest_children":{},"children_counts":{},"duration":"6.58ms"}
            """
                : """
            {"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{},"duration":"6.19ms"}
            """
        case .get(let reactionId):
            return reactionId == "00000000-0000-0000-0000-000000000002"
                ? """
            {"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hello!"},"parent":"","latest_children":{},"children_counts":{},"duration":"6.58ms"}
            """
                : """
            {"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{},"duration":"6.19ms"}
            """
        case .delete:
            return "{}"
        case .update:
            return """
            {"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hi!"},"parent":"","latest_children":{"comment":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"like":[{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}]},"children_counts":{"comment":1,"like":1},"duration":"4.89ms"}
            """
        case .reactionsByActivityId:
            return """
            {"next":"","results":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}},{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}},{"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.477491Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hi!"},"parent":"","latest_children":{"comment":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"like":[{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}]},"children_counts":{"comment":1,"like":1}}],"activity":{"actor":"eric","foreign_id":"","id":"ce918867-0520-11e9-a11e-0a286b200b2e","latest_reactions":{"comment":[{"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.477491Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hi!"},"parent":"","latest_children":{"comment":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"like":[{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}]},"children_counts":{"comment":1,"like":1}}]},"latest_reactions_extra":{"comment":{"next":""}},"object":"burger","origin":null,"own_reactions":{"comment":[{"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.477491Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hi!"},"parent":"","latest_children":{"comment":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"like":[{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}]},"children_counts":{"comment":1,"like":1}}]},"reaction_counts":{"comment":1},"target":"","time":"2018-12-21T13:03:27.424727","verb":"preparing"},"duration":"47.33ms"}
            """
        case .reactionsByReactionId(_, _, _):
            return """
            {"next":"","results":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}},{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"duration":"30.73ms"}
            """
        case .reactionsByUserId(_, let kind, _):
            return kind == nil
                ? """
            {"next":"","results":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}},{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}},{"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.477491Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hi!"},"parent":"","latest_children":{"comment":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"like":[{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}]},"children_counts":{"comment":1,"like":1}}],"duration":"57.10ms"}
            """
                : """
            {"next":"","results":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}},{"created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.477491Z","id":"50539e71-d6bf-422d-ad21-c8717df0c325","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hi!"},"parent":"","latest_children":{"comment":[{"created_at":"2018-12-27T13:02:03.242688Z","updated_at":"2018-12-27T13:02:03.242688Z","id":"c28a6b76-8193-4ad4-a96b-fa664cf318cc","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"comment","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{"text":"Hey!"},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}],"like":[{"created_at":"2018-12-27T13:02:03.128831Z","updated_at":"2018-12-27T13:02:03.128831Z","id":"c7752fd7-e0dd-46c0-893a-0de07ec47739","user_id":"eric","user":{"id":"eric","created_at":"2018-12-27T13:02:03.013191Z","updated_at":"2018-12-27T13:02:03.013191Z"},"kind":"like","activity_id":"ce918867-0520-11e9-a11e-0a286b200b2e","data":{},"parent":"50539e71-d6bf-422d-ad21-c8717df0c325","latest_children":{},"children_counts":{}}]},"children_counts":{"comment":1,"like":1}}],"duration":"3.50ms"}
            """
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
        let feedIds: FeedIds?
        
        init(activityId: String? = nil,
             parentReactionId: String? = nil,
             kind: ReactionKind? = nil,
             data: AnyEncodable,
             feedIds: FeedIds) {
            self.activityId = activityId
            self.parentReactionId = parentReactionId
            self.kind = kind
            self.data = data.encodable is EmptyReactionExtraData ? nil : data
            self.feedIds = feedIds.isEmpty ? nil : feedIds
        }
    }
}
