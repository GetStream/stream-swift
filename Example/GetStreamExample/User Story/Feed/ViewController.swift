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
    let feedGroup = FeedGroup(feedSlug: "user", userId: "eric")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let token = Token(secret: "wwzpjxsththuh56373u65rnw9bcjqxb6jxfhu5ux33b6xzyuw6vrdp9bjxg247u6") else {
            return
        }
        
        let client = Client(apiKey: "8vcd7t9ke4vy", appId: "44181", token: token, logsEnabled: true)
        print(client)
        let feed = Feed(feedGroup, client: client)
        
        let activity = Activity(actor: "eric",
                                tweet: "Hello world!",
                                foreignId: UUID().uuidString,
                                time: Date())
        activity.feedGroups = [FeedGroup(feedSlug: "timeline", userId: "jessica")]
        
        add(activity: activity, to: feed)
    }
    
    private func codable(_ activity: Activity) {
        let data = try! JSONEncoder.stream.encode(activity)
        print(String(data: data, encoding: .utf8)!)
        
        let decodedActivity = try! JSONDecoder.stream.decode(Activity.self, from: data)
        print(decodedActivity)
    }
    
    private func add(activity: Activity, to feed: Feed) {
        print("Adding...", activity)
        
        feed.add(activity, to: feedGroup) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
                self.fetch(feed)
            } else {
                print(result)
            }
        }
    }
    
    private func fetch(_ feed: Feed) {
        print("Feed requesting...")
        
        feed.feed(of: Activity.self) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
                self.removeFirstAndLastActivities(activities, in: feed)
            } else {
                print(result)
            }
        }
    }
    
    private func removeFirstAndLastActivities(_ activities: [Activity], in feed: Feed) {
        if let first = activities.first, let foreignId = first.foreignId {
            print("Deleting...", first)
            
            feed.remove(by: foreignId, feedGroup: self.feedGroup) { result in
                print("Deleted by foreignId", result)
            }
        }
        
        if let last = activities.last, let activityId = last.id {
            print("Deleting...", last)
            
            feed.remove(by: activityId, feedGroup: self.feedGroup) { result in
                print("Deleted by activityId", result)
            }
        }
    }
}
