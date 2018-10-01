//
//  Feed.swift
//  StreamAPIClient
//
//  Created by tommaso barbugli on 9/30/18.
//  Copyright © 2018 Stream.io. All rights reserved.
//

import Foundation

public class Feed {
    var group : String
    var userId : String
    
    init(_ group : String, _ userId : String) {
        self.group = group
        self.userId = userId
    }

    public func addActivity() {}
    
    public func addActivities() {}
    
    public func removeActivity(byID id:String) {}

    public func removeActivity(byForeignId id:String) {}

    public func follow(_ target : String) {}
    
    public func unfollow(_ target : String) {}

}
