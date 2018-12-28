//
//  ViewController.swift
//  GetStreamExample
//
//  Created by Alexey Bukhtin on 07/11/2018.
//  Copyright © 2018 Alexey Bukhtin. All rights reserved.
//

import UIKit
import GetStream

class ViewController: UIViewController {
    
    var subscription: SubscribedChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let secretData = "wwzpjxsththuh56373u65rnw9bcjqxb6jxfhu5ux33b6xzyuw6vrdp9bjxg247u6".data(using: .utf8)!
//        let token = Token(secretData: secretData, userId: "eric")
        let token = Token(secretData: secretData, resource: .all, permission: .all, feedId: .any)
        let client = Client(apiKey: "8vcd7t9ke4vy", appId: "44738", token: token, logsEnabled: true)
//        enrich(client)
        
        let ericFeed = client.flatFeed(feedSlug: "user", userId: "eric")
        
//        ericFeed.add(Activity(actor: "1", verb: "2", object: "3")) {
//            print($0)
//
//            if let activity = (try? $0.dematerialize())?.first {
//                ericFeed.remove(byActivityId: activity.id!) {
//                    print($0)
//                }
//            }
//        }
        
        let user = User(id: "eric", name: "Eric")
        let burger = Food(name: "Burger", id: "burger")

        ericFeed.add(UserFoodActivity(actor: user, verb: "preparing", object: burger)) {
            print($0)

            if let activity = (try? $0.dematerialize())?.first {
                ericFeed.remove(activityId: activity.id!) {
                    print($0)
                }
            }
        }
    }
    
    func enrich(_ client: Client) {
        let user = User(id: "eric", name: "Eric")
        let burger = Food(name: "Burger", id: "burger")
        let feed = client.flatFeed(feedSlug: "timeline", userId: "eric")
        
        client.create(user: user) { _ in
//            print($0)
//            client.add(collectionObject: burger) {
//                print($0)
//
        let activity = UserFoodActivity(actor: user, verb: "preparing", object: burger)
            
            feed.add(activity) {
                print($0)
                
                feed.get(typeOf: UserFoodActivity.self) {
                    print($0)
                }
            }
//            }
        }
    }
    
    func aggregation() {
        // Java client.
        let secretData = "7j7exnksc4nxy399fdxvjqyqsqdahax3nfgtp27pumpc7sfm9um688pzpxjpjbf2".data(using: .utf8)!
        let token = Token(secretData: secretData, resource: .all, permission: .all, feedId: .any)
        let client = Client(apiKey: "gp6e8sxxzud6", appId: "44738", token: token, logsEnabled: true)
        
        let aggregatedFeed = client.aggregatedFeed(feedSlug: "aggregated", userId: "777")
        
        aggregatedFeed.get(typeOf: Sport.self) {
            print($0)
        }
        
        let notificationFeed = client.notificationFeed(feedSlug: "notification", userId: "1")
        
        notificationFeed.get {
            print($0)
        }
    }
    
    func collection(_ client: Client) {
        let burger = Food(name: "Burger", id: "burger")
        
        client.add(collectionObject: burger) {
            let burger = try! $0.dematerialize()
            
            client.get(typeOf: Food.self, collectionName: "food", collectionObjectId: burger.id!) {
                let burger = try! $0.dematerialize()
                print(burger.id ?? "<No Id>", burger.name)
                burger.name = "Cheeseburger"
                
                client.update(collectionObject: burger) {
                    let cheeseburger = try! $0.dematerialize()
                    print(cheeseburger.id ?? "<No Id>", cheeseburger.name)
                    
                    client.delete(collectionObject: burger) {
                        print($0)
                    }
                }
            }
        }
    }
    
    func user(_ client: Client) {
        let user = User(id: "eric", name: "Eric")
        
        client.create(user: user) {
            print($0)
            let user = try! $0.dematerialize()
            
            client.get(typeOf: User.self, userId: user.id) {
                print($0)
                let loadedUser = try? $0.dematerialize()
                loadedUser?.name = "Alex2"
                
                client.update(user: loadedUser!, completion: {
                    print($0)
                    let updatedUser = try? $0.dematerialize()
                    
                    client.delete(userId: updatedUser!.id, completion: {
                        print($0)
                        
                        client.get(userId: updatedUser!.id) {
                            print($0)
                        }
                    })
                })
            }
        }
    }
    
    func findReactions(_ client: Client) {
//        client.reactions(forUserId: "eric", kindOf: .comment) {
//            let reactions = try! $0.dematerialize()
//            print(reactions.reactions)
//        }
//
//        client.reactions(forReactionId: UUID(uuidString: "50539e71-d6bf-422d-ad21-c8717df0c325")!) {
//            let reactions = try! $0.dematerialize()
//            print(reactions)
//        }
        
        client.reactions(forActivityId: UUID(uuidString: "ce918867-0520-11e9-a11e-0a286b200b2e")!, withActivityData: true) {
            let reactions = try! $0.dematerialize()
            print(reactions)
            print(reactions.reactions)
            print(try! reactions.activity(typeOf: EnrichedActivity<User, Food, String>.self))
        }
    }
    
    func reactions(_ client: Client) {
        let ericFeed = client.flatFeed(feedSlug: "timeline", userId: "eric")
        
        ericFeed.get(typeOf: Tweet.self, enrich: false) { activitiesResult in
            let activity = (try! activitiesResult.dematerialize()).first!
            
            client.add(reactionTo: activity.id!, kindOf: .comment, extraData: Comment(text: "Hello!")) {
                let commentReaction = try! $0.dematerialize()
                print(commentReaction)
                
                client.add(reactionTo: activity.id!, parentReactionId: commentReaction.id, kindOf: .like) {
                    let likeReaction = try! $0.dematerialize()
                    print(likeReaction)
                    
                    client.add(reactionTo: activity.id!,
                               parentReactionId: commentReaction.id,
                               kindOf: .comment,
                               extraData: Comment(text: "Hey!")) { result in
                                let heyReaction = try! result.dematerialize()
                                print(heyReaction)
                                
                                client.get(reactionId: commentReaction.id, extraDataTypeOf: Comment.self) {
                                    let loadedReaction = try! $0.dematerialize()
                                    print(loadedReaction)
                                    
                                    client.update(reactionId: loadedReaction.id, extraData: Comment(text: "Hi!")) {
                                        let updatedReaction = try! $0.dematerialize()
                                        print("1️⃣", updatedReaction)
                                        self.findReactions(client, reaction: updatedReaction)
                                        print("2️⃣", updatedReaction.latestChildren(kindOf: .like))
                                        print("2️⃣", updatedReaction.latestChildren(kindOf: .comment,
                                                                                        extraDataTypeOf: Comment.self))
                                        //
                                        //                                                client.delete(reactionId: updatedReaction.id) { print("✖️", $0) }
                                    }
                                }
                    }
                }
            }
        }
    }
    
    func findReactions(_ client: Client, reaction: Reaction<Comment>) {
        client.reactions(forActivityId: reaction.activityId) {
            print($0)
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
        let ericFeed = client.flatFeed(feedSlug: "user", userId: "eric")
        
        subscription = ericFeed.subscribe(typeOf: Tweet.self) { result in
            print(#function, result)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let activity = Tweet(actor: "eric", tweet: "realtime")
            activity.foreignId = "realtime"
            
            ericFeed.add(activity, completion: { result in
                print(result)
                let activities = try? result.dematerialize()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let activityId = activities?.first?.foreignId {
                        ericFeed.remove(foreignId: activityId, completion: { result in
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
        
        let ericFeed = client.flatFeed(feedSlug: "timeline", userId: "eric")
        //        let jessicaFeed = client.feed(feedSlug: "timeline", userId: "jessica")
        
        //        let activity = Activity(actor: "eric", tweet: "A test tweet.")
        
        //        ericFeed.add(activity) {
        //            print($0)
        
        ericFeed.get(typeOf: Tweet.self, ranking: "popular") { result in
            print(try! result.dematerialize())
        }
        //        }
    }
    
    func followers(_ client: Client) {
        let ericFeed = client.flatFeed(feedSlug: "user", userId: "eric")
        //        let jessicaFeed = client.feed(feedSlug: "timeline", userId: "jessica")
        //        jessicaFeed.follow(to: ericFeed.feedId) {
        //            print($0)
        ericFeed.following() { print($0) }
        ericFeed.followers { print($0) }
        //        }
    }
    
    func setUnsetProperties(_ client: Client) {
        client.updateActivity(typeOf: Tweet.self,
                              setProperties: ["tweet": "new"],
                              activityId: UUID(uuidString: "42EC2427-E99F-11E8-A1AD-127939012AF0")!) {
                                print($0)
                                self.fetchActivities(client)
        }
        
        client.updateActivity(typeOf: Tweet.self,
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
        
        client.get(typeOf: Tweet.self, activityIds: activityIds) { result in
            print(result)
        }
        
        let foreignIds = ["D05B0F4D-4DDB-4154-9565-DD424CC70A67",
                          "1C2C6DAD-5FBD-4DA6-BD37-BDB67E2CD1D6"]
        
        let times = ["2018-11-16T12:58:06.664401".streamDate!,
                     "2018-11-14T11:00:32.282000".streamDate!]
        
        client.get(typeOf: Tweet.self, foreignIds: foreignIds, times: times) { result in
            print(result)
        }
    }
    
    func updateActivity(_ client: Client) {
        let ericFeed = client.flatFeed(feedSlug: "user", userId: "eric")
        
        ericFeed.get(typeOf: Tweet.self) { result in
            if case .success(let activities) = result, let first = activities.first {
                print(first)
                
                guard let foreignId = first.foreignId, !foreignId.isEmpty else {
                    ericFeed.remove(activityId: first.id!, completion: { result in
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
        let ericFeed = client.flatFeed(ericFeedId)
        let jessicaFeed = client.flatFeed(jessicaFeedId)
        
        print("Following...")
        ericFeed.follow(to: jessicaFeedId) { result in
            self.fetchFeed(ericFeed) {
                self.fetchFeed(jessicaFeed) {
                    print("Unfollowing...")
                    ericFeed.unfollow(from: jessicaFeedId) { _ in
                        self.fetchFeed(ericFeed) {
                            self.fetchFeed(jessicaFeed) {}
                        }
                    }
                }
            }
        }
    }
    
    func add(activity: Tweet, to feed: FlatFeed) {
        print("Adding to \(feed)...", activity)
        
        feed.add(activity) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
                self.fetchFeed(feed)
            } else {
                print(result)
            }
        }
    }
    
    func fetchFeed(_ feed: FlatFeed, completion: (() -> Void)? = nil) {
        print("Fetching feed \(feed)...")
        
        feed.get(typeOf: Tweet.self) { result in
            if case .success(let activities) = result {
                activities.forEach { activity in
                    debugPrint(activity)
                }
                
                completion?()
            } else {
                print(result)
            }
        }
    }
    
    func removeFirstAndLastActivities(_ activities: [Tweet], in feed: Feed) {
        if let first = activities.first, let foreignId = first.foreignId {
            print("Deleting from \(feed)...", first)
            
            feed.remove(foreignId: foreignId) { result in
                print("Deleted by foreignId", result)
            }
        }
        
        if let last = activities.last, let activityId = last.id {
            print("Deleting from \(feed)...", last)
            
            feed.remove(activityId: activityId) { result in
                print("Deleted by activityId", result)
            }
        }
    }
    
    func codable(_ activity: Tweet) {
        let data = try! JSONEncoder.stream.encode(activity)
        print(String(data: data, encoding: .utf8)!)
        
        let decodedActivity = try! JSONDecoder.stream.decode(Tweet.self, from: data)
        print(decodedActivity)
    }
}
