import PlaygroundSupport
import Foundation
import GetStream
PlaygroundPage.current.needsIndefiniteExecution = true

//: [Previous](@previous)
//: ## Quick start

// Setup the Stream client
// This token must be received from your server.
let token = Token(secretData: "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav".data(using: .utf8)!)

let client = Client(apiKey: "3gmch3yrte9d", appId: "44738", token: token)

// Setup Eric feed.
let ericFeed = client.feed(feedSlug: "user", userId: "eric")

startSync()

ericFeed.add(Activity(actor: "eric", verb: "add", object: "picture:10")) { result in
    if case .success(let activities) = result {
        print("Eric added activities:\n", activities)
    } else {
        print(result)
    }
    
    endSync()
}

waitSync()

// Setup Jessica feed.
let jessicaFeed = client.feed(feedSlug: "timeline", userId: "jessica")

// Jessica will follow to Eric's feed.
jessicaFeed.follow(to: ericFeed.feedId) { result in
    if case .success = result {
        print("Jessica is following to the Eric's feed.")
    }
    
    endSync()
}

waitSync()

// Get Jessica's feed activities.
jessicaFeed.get(typeOf: Activity.self) { result in
    if case .success(let activities) = result {
        print("Jessica feed:")
        activities.forEach { print($0) }
    } else {
        print(result)
    }
    
    endSync(true)
}
//: [Next](@next)
