//
//  ViewController.swift
//  GetStreamExample
//
//  Created by Alexey Bukhtin on 07/11/2018.
//  Copyright © 2018 Alexey Bukhtin. All rights reserved.
//

import UIKit
import GetStream

struct Comment: ReactionExtraDataProtocol {
    let text: String
}

class ViewController: UIViewController {
    
    var subscription: SubscribedChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let secretData = "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav".data(using: .utf8)!
        let token = Token(secretData: secretData, userId: "eric")
        let client = Client(apiKey: "3gmch3yrte9d",
                            appId: "44738",
                            token: token,
                            logsEnabled: true)
        
        reactions(client)
    }
    
    func reactions(_ client: Client) {
        let ericFeed = client.feed(feedSlug: "timeline", userId: "eric")
        
        ericFeed.get(typeOf: Activity.self) { activitiesResult in
            let activity = (try! activitiesResult.dematerialize()).first!
            
            client.addReaction(to: activity.id!, kindOf: .comment, data: Comment(text: "Hello!")) { result in
                let commentReaction = try! result.dematerialize()
                print(commentReaction)
                
                client.addReaction(to: activity.id!, parentReactionId: commentReaction.id, kindOf: .like) { result in
                    let likeReaction = try! result.dematerialize()
                    print(likeReaction)
                    
                    client.addReaction(to: activity.id!,
                                       parentReactionId: commentReaction.id,
                                       kindOf: .comment,
                                       data: Comment(text: "Hey!")) { result in
                                        let heyReaction = try! result.dematerialize()
                                        print(heyReaction)
                                        
                                        client.reaction(id: commentReaction.id, extraDataTypeOf: Comment.self) { result in
                                            let loadedReaction = try! result.dematerialize()
                                            print(loadedReaction)
                                            
                                            client.update(reactionId: loadedReaction.id, data: Comment(text: "Hi!")) { result in
                                                let updatedReaction = try! result.dematerialize()
                                                print("1️⃣", updatedReaction)
                                                
                                                do {
                                                    print("2️⃣", updatedReaction.latestChildren(kind: .comment))
                                                } catch {
                                                    print("❌", error)
                                                }
                                                
                                                //                            client.delete(reactionId: updatedReaction.id) { result in
                                                //                                print("✖️", result)
                                                //                            }
                                            }
                                        }
                    }
                }
            }
        }
    }
    
    func checkOG(_ client: Client) {
        client.og(url: URL(string: "https://www.imdb.com/title/tt2084970/")!) { result in
            print(result)
        }
    }
    
    func checkFilesAndImages(_ client: Client) {
        guard let image = UIImage(named: "niffler"),
            let file = File(name: "test.jpg", jpegImage: image) else {
                return
        }
        
        client.upload(image: file) { result in
            print(result)
            
            if let url = try? result.dematerialize() {
                let imageProcess = ImageProcess(url: url, width: 100, height: 100)
                
                client.resizeImage(imageProcess: imageProcess, completion: { result in
                    print(result)
                    
                    client.delete(imageURL: url, completion: { result in
                        print(result)
                    })
                })
            }
        }
    }
    
    func checkSubscriptions(_ client: Client) {
        let ericFeed = client.feed(feedSlug: "user", userId: "eric")
        
        subscription = ericFeed.subscribe(typeOf: Activity.self) { result in
            print(#function, result)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let activity = Activity(actor: "eric", tweet: "realtime")
            activity.foreignId = "realtime"
            
            ericFeed.add(activity, completion: { result in
                print(result)
                let activities = try? result.dematerialize()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let activityId = activities?.first?.foreignId {
                        ericFeed.remove(by: activityId, completion: { result in
                            print(result)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.subscription = nil
                            }
                        })
                    }
                }
            })
        }
    }
    
    func stream() {
        let token = Token(secretData: "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav".data(using: .utf8)!)
        let client = Client(apiKey: "3gmch3yrte9d", appId: "44738", token: token, logsEnabled: true)
        
        let ericFeed = client.feed(feedSlug: "timeline", userId: "eric")
        //        let jessicaFeed = client.feed(feedSlug: "timeline", userId: "jessica")
        
        //        let activity = Activity(actor: "eric", tweet: "A test tweet.")
        
        //        ericFeed.add(activity) {
        //            print($0)
        
        ericFeed.get(typeOf: Activity.self, ranking: "popular") { result in
            print(try! result.dematerialize())
        }
        //        }
    }
    
    func followers(_ client: Client) {
        let ericFeed = client.feed(feedSlug: "user", userId: "eric")
        //        let jessicaFeed = client.feed(feedSlug: "timeline", userId: "jessica")
        //        jessicaFeed.follow(to: ericFeed.feedId) {
        //            print($0)
        ericFeed.following() { print($0) }
        ericFeed.followers { print($0) }
        //        }
    }
    
    func setUnsetProperties(_ client: Client) {
        client.updateActivity(typeOf: Activity.self,
                              setProperties: ["tweet": "new"],
                              activityId: UUID(uuidString: "42EC2427-E99F-11E8-A1AD-127939012AF0")!) {
                                print($0)
                                self.fetchActivities(client)
        }
        
        client.updateActivity(typeOf: Activity.self,
                              setProperties: ["tweet": "new2"],
                              foreignId: "D05B0F4D-4DDB-4154-9565-DD424CC70A67",
                              time: "2018-11-16T12:58:06.664401".streamDate!) {
                                print($0)
                                self.fetchActivities(client)
        }
    }
    
    func fetchActivities(_ client: Client) {
        let activityIds = [UUID(uuidString: "42EC2427-E99F-11E8-A1AD-127939012AF0")!,
                           UUID(uuidString: "815B4FA0-E7FC-11E8-8080-80007911093A")!]
        
        client.get(typeOf: Activity.self, activityIds: activityIds) { result in
            print(result)
        }
        
        let foreignIds = ["D05B0F4D-4DDB-4154-9565-DD424CC70A67",
                          "1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6"]
        
        let times = ["2018-11-16T12:58:06.664401".streamDate!,
                     "2018-11-14T11:00:32.282000".streamDate!]
        
        client.get(typeOf: Activity.self, foreignIds: foreignIds, times: times) { result in
            print(result)
        }
    }
    
    func updateActivity(_ client: Client) {
        let ericFeed = client.feed(feedSlug: "user", userId: "eric")
        
        ericFeed.get(typeOf: Activity.self) { result in
            if case .success(let activities) = result, let first = activities.first {
                print(first)
                
                guard let foreignId = first.foreignId, !foreignId.isEmpty else {
                    ericFeed.remove(by: first.id!, completion: { result in
                        print(result)
                    })
                    return
                }
                
                client.update(activities: [first]) { result in
                    print(result)
                }
            }
        }
    }
    
    func follow(client: Client) {
        let ericFeedId = FeedId(feedSlug: "user", userId: "eric")
        let jessicaFeedId = FeedId(feedSlug: "timeline", userId: "jessica")
        let ericFeed = client.feed(ericFeedId)
        let jessicaFeed = client.feed(jessicaFeedId)
        
        print("Following...")
        ericFeed.follow(to: jessicaFeedId) { result in
            self.fetch(ericFeed) {
                self.fetch(jessicaFeed) {
                    print("Unfollowing...")
                    ericFeed.unfollow(from: jessicaFeedId) { _ in
                        self.fetch(ericFeed) {
                            self.fetch(jessicaFeed) {}
                        }
                    }
                }
            }
        }
    }
    
    func add(activity: Activity, to feed: Feed) {
        print("Adding to \(feed)...", activity)
        
        feed.add(activity) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
                self.fetch(feed)
            } else {
                print(result)
            }
        }
    }
    
    func fetch(_ feed: Feed, completion: (() -> Void)? = nil) {
        print("Fetching feed \(feed)...")
        
        feed.get(typeOf: Activity.self) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
                completion?()
            } else {
                print(result)
            }
        }
    }
    
    func removeFirstAndLastActivities(_ activities: [Activity], in feed: Feed) {
        if let first = activities.first, let foreignId = first.foreignId {
            print("Deleting from \(feed)...", first)
            
            feed.remove(by: foreignId) { result in
                print("Deleted by foreignId", result)
            }
        }
        
        if let last = activities.last, let activityId = last.id {
            print("Deleting from \(feed)...", last)
            
            feed.remove(by: activityId) { result in
                print("Deleted by activityId", result)
            }
        }
    }
    
    func codable(_ activity: Activity) {
        let data = try! JSONEncoder.Stream.default.encode(activity)
        print(String(data: data, encoding: .utf8)!)
        
        let decodedActivity = try! JSONDecoder.Stream.default.decode(Activity.self, from: data)
        print(decodedActivity)
    }
}
