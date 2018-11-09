//
//  ViewController.swift
//  GetStreamExample
//
//  Created by Alexey Bukhtin on 07/11/2018.
//  Copyright © 2018 Alexey Bukhtin. All rights reserved.
//

import UIKit
import GetStream

let streamToken: Token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6ImZlZWQiLCJhY3Rpb24iOiJyZWFkIiwiZmVlZF9pZCI6InRpbWVsaW5lX2FnZ3JlZ2F0ZWQxMjMifQ.K2cJAMhj1B3RQng-6LjyyMcIEnl3NRAi60etSwvy6zA"

class ViewController: UIViewController {
    
    let client = Client(apiKey: "8vcd7t9ke4vy", appId: "44223", token: streamToken, baseURL: BaseURL(location: .europeWest))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let feedId = FeedId(feedSlug: "user", userId: "eric")
        var feed = Feed(feedId, client: client)
        
        feed.feed { result in
            print(result)
        }
    }
}
