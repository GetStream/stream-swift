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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let token = Token(secret: "wwzpjxsththuh56373u65rnw9bcjqxb6jxfhu5ux33b6xzyuw6vrdp9bjxg247u6") else {
            return
        }
        
        let client = Client(apiKey: "8vcd7t9ke4vy", appId: "44181", token: token)
        follow(client: client)
    }
    
    private func follow(client: Client) {
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
    
    private func add(activity: Activity, to feed: Feed) {
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
    
    private func fetch(_ feed: Feed, completion: (() -> Void)? = nil) {
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
    
    private func removeFirstAndLastActivities(_ activities: [Activity], in feed: Feed) {
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
    
    private func codable(_ activity: Activity) {
        let data = try! JSONEncoder.stream.encode(activity)
        print(String(data: data, encoding: .utf8)!)
        
        let decodedActivity = try! JSONDecoder.stream.decode(Activity.self, from: data)
        print(decodedActivity)
    }
}
