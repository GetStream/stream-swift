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
        let feedGroup = FeedGroup(feedSlug: "user", userId: "eric")
        var feed = Feed(feedGroup, client: client)
        
        feed.feed(of: Activity.self) { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
            }
        }
        
        feed.feed { result in
            if case .success(let activities) = result {
                activities.forEach { print($0) }
            }
        }
    }
}
