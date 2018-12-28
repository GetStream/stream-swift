//: [Previous](@previous)
//: ## Quick start
//: The quickstart below shows you how to build a scalable social network. It higlights the most common API calls:
import PlaygroundSupport
import GetStream
PlaygroundPage.current.needsIndefiniteExecution = true
startSync()

// This token should be received from your server.
let token = Token(secretData: "<#Secret#>".data(using: .utf8)!)

// Setup Stream client.
let client = Client(apiKey: "<#ApiKey#>", appId: "<#AppId#>", token: token)

// Create Chris's user feed.
let chrisFeed = client.flatFeed(feedSlug: "user", userId: "chris")

// Create an Activity. You can make own Activity class or stryct with custom properties.
let activity = Activity(actor: "chris", verb: "add", object: "picture:10", foreignId: "picture:10")

chrisFeed.add(activity) { result in
    // A result of the adding of the activity.
    print(result)
    endSync() // playground: end async code.
}

waitSync() // playground: wait the end of the prev async code

// Create a following relationship between Jack's "timeline" feed and Chris' "user" feed:
let jackFeed = client.flatFeed(feedSlug: "timeline", userId: "jack")
jackFeed.follow(to: chrisFeed.feedId, activityCopyLimit: 1) { result in
    print(result)
    endSync()
}

waitSync()

// Read Jack's timeline and Chris' post appears in the feed:
jackFeed.get(pagination: .limit(10)) { result in
    let activities = try! result.dematerialize()
    print(activities)
    endSync()
}

waitSync()

// Remove an activity by referencing it's foreignId
chrisFeed.remove(foreignId: "picture:10") { result in
    print(result)
    endSync(finishPlayground: true)
}
//: [Next](@next)
