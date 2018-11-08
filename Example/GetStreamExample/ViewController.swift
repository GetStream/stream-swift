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
    let client = Client(apiKey: "8vcd7t9ke4vy", appId: "44223")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let feedId = FeedId(feedSlug: "timeline_aggregated", userId: "123")
        client.feed(with: feedId)
    }
}
