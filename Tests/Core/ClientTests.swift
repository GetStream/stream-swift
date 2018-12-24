//
//  ClientTests.swift
//  GetStream
//
//  Created by Alexey Bukhtin on 14/11/2018.
//  Copyright © 2018 Stream.io Inc. All rights reserved.
//

import XCTest
import Moya
@testable import GetStream

extension Client {
    static var test: Client {
        let provider = NetworkProvider(stubClosure: NetworkProvider.immediatelyStub)
        let client = Client(apiKey: "apiKey",
                            appId: "appId",
                            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZXJpYyJ9.20YPOjP1-HtwKH7SH3k5CgLLLrhLCLaKDnb8XuiU7oA",
                            networkProvider: provider)
        return client
    }
}

final class ClientTests: TestCase {
    
    lazy var client = Client.test
    let feedId = FeedId(feedSlug: "test", userId: "123")

    func testConstructor() {
        let client = Client(apiKey: "", appId: "appId", token: "")
        XCTAssertEqual(client.description, "GetStream Client v.\(Client.version) appId: appId")
        _ = Client(apiKey: "", appId: "appId", token: "", logsEnabled: true)
        _ = Client(apiKey: "", appId: "appId", token: "", callbackQueue: DispatchQueue.main)
    }
    
    func testEndpointMapper() {
        let feedId = FeedId(feedSlug: "test", userId: "123")
        let apiKey = "testKey"
        let ranking = "r"
        let target = FeedEndpoint.get(feedId, true, .none, ranking, .none, [])
        let endpoint = Client.endpointMapping(MultiTarget(target), apiKey: apiKey, baseURL: BaseURL())
        
        if case .networkResponse(_, let sampleData) = endpoint.sampleResponseClosure() {
            XCTAssertEqual(sampleData, target.sampleData)
        }
        
        if case let .requestParameters(urlParameters, _) = endpoint.task, let parameters = urlParameters as? [String: String] {
            XCTAssertEqual(parameters, ["api_key": apiKey, "ranking": ranking])
        }
    }
    
    func testFeedEndpointGet() {
        expect("feed") { test in
            client.request(endpoint: FeedEndpoint.get(feedId, true, .none, "", .none, [])) { result in
                if case .success(let response) = result,
                    let json = (try? response.mapJSON()) as? JSON,
                    let activities = json["results"] as? [Any] {
                    XCTAssertEqual(activities.count, 3)
                    test.fulfill()
                }
            }
        }
    }
    
    func testFeedEndpointAddActivity() {
        expect("add activity to the feed") { test in
            let activity = Activity(actor: "tester", verb: "test", object: "add activity")
            XCTAssertEqual(activity.description, "EnrichedActivity<String, String, String><n/a> foreignId: n/a tester test add activity at <n/a> feedIds: []")
            
            client.request(endpoint: FeedActivityEndpoint.add(activity, feedId: feedId)) { result in
                if case .success(let response) = result,
                    let json = (try? response.mapJSON()) as? JSON {
                    XCTAssertEqual(json["actor"] as! String, activity.actor)
                    XCTAssertEqual(json["verb"] as! String, activity.verb)
                    XCTAssertEqual(json["object"] as! String, activity.object)
                    test.fulfill()
                }
            }
        }
    }
    
    func testActivityBaseURL() {
        let endpoint = ActivityEndpoint<Activity>.getByIds([.test1])
        XCTAssertEqual(endpoint.baseURL, BaseURL.placeholderURL)
    }
    
    func testClientActivityGetByIds() {
        expect("get an activity by id") { test in
            client.get(typeOf: Activity.self, activityIds: [.test1, .test2]) { result in
                if case .success(let activities) = result {
                    XCTAssertEqual(activities.count, 2)
                    XCTAssertEqual(activities[0].id!, .test1)
                    XCTAssertEqual(activities[1].id!, .test2)
                    test.fulfill()
                }
            }
        }
    }
    
    func testClientActivityGetByForeignIds() {
        expect("get an activity by foreignId") { test in
            let foreignIds = ["f1", "f2"]
            let times = [Date(timeIntervalSinceNow: -10), Date(timeIntervalSinceNow: -20)]
            
            client.get(typeOf: Activity.self, foreignIds: foreignIds, times: times) { result in
                if case .success(let activities) = result {
                    XCTAssertEqual(activities.count, 2)
                    XCTAssertEqual(activities[0].foreignId!, foreignIds[0])
                    XCTAssertEqual(activities[1].foreignId!, foreignIds[1])
                    XCTAssertEqual(activities[0].time!.stream, times[0].stream)
                    XCTAssertEqual(activities[1].time!.stream, times[1].stream)
                    test.fulfill()
                }
            }
        }
    }
    
    func testClientActivitiesUpdate() {
        expect("activities updated") { test in
            let activity = Activity(actor: "tester", verb: "update", object: "activities")
            
            client.update(activities: [activity]) { result in
                if case .success(let statusCode) = result {
                    XCTAssertEqual(statusCode, 200)
                    test.fulfill()
                }
            }
        }
    }
    
    func testClientActivityUpdateById() {
        expect("an activity updated by id") { test in
            client.updateActivity(typeOf: Activity.self,
                                  setProperties: ["object": "updated"],
                                  unsetPropertiesNames: ["image"],
                                  activityId: .test1) { result in
                                    if case .success(let activities) = result, let activity = activities.first {
                                        XCTAssertEqual(activity.id!, .test1)
                                        XCTAssertEqual(activity.object, "updated")
                                        test.fulfill()
                                    }
            }
        }
    }
    
    func testClientActivityUpdateByForeignId() {
        expect("an activity updated by foreignId") { test in
            let time = Date()
            client.updateActivity(typeOf: Activity.self,
                                  setProperties: ["object": "updated"],
                                  unsetPropertiesNames: ["image"],
                                  foreignId: "f1",
                                  time: time) { result in
                                    if case .success(let activities) = result, let activity = activities.first {
                                        XCTAssertEqual(activity.foreignId, "f1")
                                        XCTAssertEqual(activity.object, "updated")
                                        XCTAssertEqual(activity.time!.stream, time.stream)
                                        test.fulfill()
                                    }
            }
        }
    }
    
    func testJSONInvalid() {
        failRequests(clientError: .jsonInvalid)
    }
    
    func testFailedMapDataToJSON() {
        failRequests(clientError: .network("Failed to map data to JSON.", nil))
    }
    
    func testExceptionInJSON() {
        failRequests(clientError: .server(.init(json: ["exception": 0])))
    }
    
    func failRequests(clientError: ClientError) {
        expect(clientError.localizedDescription) { test in
            let activity = Activity(actor: clientError.localizedDescription, verb: "", object: "")
            
            client.request(endpoint: FeedActivityEndpoint.add(activity, feedId: feedId)) { result in
                if case .failure(let error) = result {
                    XCTAssertEqual(error.localizedDescription, clientError.localizedDescription)
                    test.fulfill()
                }
            }
        }
    }
    
    func testEnrich() {
        var endpoint = FeedEndpoint.get(feedId, false, .none, "", .none, [])
        XCTAssertEqual(endpoint.path, "feed/test/123/")
        endpoint = FeedEndpoint.get(feedId, true, .none, "", .none, [])
        XCTAssertEqual(endpoint.path, "enrich/feed/test/123/")
    }
    
    func testReactions() {
        var endpoint = FeedEndpoint.get(feedId, false, .none, "", .none, [])
        
        guard case .requestPlain = endpoint.task else {
            XCTFail()
            return
        }

        endpoint = FeedEndpoint.get(feedId, false, .none, "", .none, .includeOwn)
        
        if case .requestParameters(let parameters, _) = endpoint.task {
            XCTAssertEqual(parameters as! [String: Bool], ["withOwnReactions": true])
        } else {
            XCTFail()
        }

        endpoint = FeedEndpoint.get(feedId, false, .none, "", .none, .includeAll)
        
        if case .requestParameters(let parameters, _) = endpoint.task {
            XCTAssertEqual(parameters as! [String: Bool], ["withOwnReactions": true,
                                                           "withOwnChildren": true,
                                                           "withRecentReactions": true,
                                                           "withReactionCounts": true])
        } else {
            XCTFail()
        }
    }
    
    func testPagination() {
        // with limit 5.
        var endpoint = FeedEndpoint.get(feedId, true, .limit(5), "", .none, [])
        
        if case .requestParameters(let limitParameters, _) = endpoint.task {
            XCTAssertEqual(limitParameters as! [String: Int], ["limit": 5])
        }
        
        // with offset and limit
        endpoint = .get(feedId, true, .limit(5), "", .none, [])
        
        if case .requestParameters(let offsetParameters, _) = endpoint.task {
            XCTAssertEqual(offsetParameters as! [String: Int], ["limit": 5])
        }
        
        // with great then id and limit
        let someId1 = "someId1"
        let someId2 = "someId2"
        var pagination: Pagination = .limit(5) + .greaterThan(someId1)
        pagination += .lessThan(someId2)
        endpoint = .get(feedId, true,  pagination, "", .none, [])
        
        if case .requestParameters(let parameters, _) = endpoint.task {
            XCTAssertEqual(parameters["limit"] as! Int, 5)
            XCTAssertEqual(parameters["id_gt"] as! String, someId1)
            XCTAssertEqual(parameters["id_lt"] as! String, someId2)
        }
    }
    
    func testRateLimit() {
        let response = Response(statusCode: 200, data: Data())
        XCTAssertNil(Client.RateLimit(response: response))
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let httpResponse = HTTPURLResponse(url: BaseURL.placeholderURL,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["x-ratelimit-limit": "20",
                                                          "x-ratelimit-remaining": "10",
                                                          "x-ratelimit-reset": String(timestamp)])
        let rateLimit = Client.RateLimit(response: Response(statusCode: 200, data: Data(), response: httpResponse))
        XCTAssertNotNil(rateLimit)
        
        if let rateLimit = rateLimit {
            XCTAssertEqual(rateLimit.limit, 20)
            XCTAssertEqual(rateLimit.remaining, 10)
            XCTAssertEqual(rateLimit.resetDate, Date(timeIntervalSince1970: TimeInterval(timestamp)))
        }
    }
    
    func testClientError() {
        let info = ClientError.Info(json: ["detail": "DETAIL", "code": 1, "status_code": 2, "exception": "EXCEPTION"])
        XCTAssertEqual(info.description, "EXCEPTION[1] Status Code: 2, DETAIL")
        
        let emptyInfo = ClientError.Info(json: ["empty":"json"])
        XCTAssertEqual(emptyInfo.description, "JSON response [\"empty\": \"json\"]")
        
        ClientError.warning(for: [], missedParameter: "test")
        
        let unknownError = ClientError.unexpectedError
        XCTAssertEqual(unknownError.localizedDescription, "Unexpected behaviour")
        
        XCTAssertEqual(ClientError.unknownError(unknownError.localizedDescription, unknownError).localizedDescription,
                       "Unexpected behaviour with error: Unexpected behaviour")
        
        XCTAssertEqual(ClientError.jsonEncode("test", nil).localizedDescription, "JSON encoding error: test")
        
        XCTAssertEqual(ClientError.jsonDecode("test", nil, Data()).localizedDescription,
                       "JSON decoding error: test. Data: 0 bytes")
    }
    
    func testMoyaAuthPlugin() {
        let token: Token = "123"
        let auth = AuthorizationMoyaPlugin(token: token)
        let request = URLRequest(url: URL(string: "https://getstream.io")!)
        let authRequest = auth.prepare(request, target: FeedEndpoint.deleteByForeignId("", feedId: FeedId.any))
        XCTAssertEqual(authRequest.allHTTPHeaderFields!["Stream-Auth-Type"], "jwt")
        XCTAssertEqual(authRequest.allHTTPHeaderFields!["Authorization"], token)
    }
    
    func testMoyaError() {
        XCTAssertEqual(MoyaError.requestMapping("Test.").clientError.localizedDescription,
                       "Moya error: Failed to map Endpoint to a URLRequest.")
    }
    
    func testBaseURL() {
        let testURL = "https://google.com"
        let baseURL = BaseURL(customURL: URL(string: testURL)!)
        XCTAssertEqual(baseURL.description, testURL)
        XCTAssertEqual(baseURL.endpointURLString(targetPath: ""), testURL)
        XCTAssertEqual(baseURL.endpointURLString(targetPath: "test"), testURL.appending("/test"))
    }
}
