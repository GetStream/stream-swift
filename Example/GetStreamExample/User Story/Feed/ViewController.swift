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

        let client = Client(apiKey: "8vcd7t9ke4vy", appId: "44181", token: token)
        let feed = Feed(feedGroup, client: client)
        
        let activity = Activity(actor: "eric", verb: "tweet", object: "test\(arc4random_uniform(100))")
        activity.foreignId = "6"
        activity.tweet = "Please, Delete me!"
        
        print("Adding...")
        feed.add(activity, to: feedGroup) { result in
            if case .success(let activities) = result {
                activities.forEach {
                    print($0)
                }
                
                self.fetchFeed(with: feed)
            } else {
                print(result)
            }
        }
    }
    
    private func fetchFeed(with feed: Feed) {
        print("Feed requesting...")
        
        feed.feed(of: Activity.self) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
                
                if let first = activities.first, let foreignId = first.foreignId {
                    print("Deleting...", first)
                    
                    feed.remove(by: foreignId, feedGroup: self.feedGroup) { result in
                        print(result)
                    }
                }
            } else {
                print(result)
            }
        }
    }
}
