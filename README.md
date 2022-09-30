# Stream Swift Client

[![Build Status](https://github.com/GetStream/stream-swift/workflows/CI/badge.svg)](https://github.com/GetStream/stream-swift/actions)
[![Code Coverage](https://codecov.io/gh/GetStream/stream-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/GetStream/stream-swift)
[![Language: Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://swift.org)
[![Documentation](https://github.com/GetStream/stream-swift/blob/master/docs/badge.svg)](https://getstream.github.io/stream-swift/)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/GetStream.svg)](https://cocoapods.org/pods/GetStream)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

[stream-swift](https://github.com/GetStream/stream-swift) is a Swift client for [Stream](https://getstream.io/).

You can sign up for a Stream account at https://getstream.io/get_started.

[API Docs](https://getstream.github.io/stream-swift/)

[API Examples](https://github.com/GetStream/stream-swift/wiki)</b>

## :warning: Client-side SDK no longer actively maintained by Stream

A Feeds integration includes a combination of server-side and client-side code and the interface can vary widely which is why we are no longer focussing on supporting this SDK. If you are starting from scratch we recommend you only use the server-side SDKs. 

This is by no means a reflection of our commitment to maintaining and improving the Feeds API which will always be a product that we support.

We continue to welcome pull requests from community members in case you want to improve this SDK.

## Installation

### CocoaPods

For Stream, use the following entry in your `Podfile`:

for Swift 5:
```
pod 'GetStream', '~> 2.0'
```
for Swift 4.2:
```
pod 'GetStream', '~> 1.0'
```
Then run `pod install`.

In any file you'd like to use Stream in, don't forget to import the framework with `import GetStream`.

### Swift Package Manager

To integrate using Apple's Swift package manager, add the following as a dependency to your `Package.swift`:
```
.package(url: "https://github.com/GetStream/stream-swift.git", .upToNextMajor(from: "1.0.0"))
```

### Carthage

Make the following entry in your Cartfile:
```
github "GetStream/stream-swift"
```
Then run `carthage update`.

## Quick start

```swift
// Setup a shared Stream client.
Client.config = .init(apiKey: "<#ApiKey#>", appId: "<#AppId#>", token: "<#Token#>")

// Setup a Stream current user with the userId from the Token.
Client.shared.createCurrentUser() { _ in 
    // Do all your requests from here. Reload feeds and etc.
}

// Create a user feed.
let userFeed = Client.shared.flatFeed(feedSlug: "user")

// Create an Activity. You can make own Activity class or struct with custom properties.
let activity = Activity(actor: User.current!, verb: "add", object: "picture:10", foreignId: "picture:10")

userFeed?.add(activity) { result in
    // A result of the adding of the activity.
    print(result)
}

// Create a following relationship between "timeline" feed and "user" feed:
let timelineFeed = Client.shared.flatFeed(feedSlug: "timeline")

timelineFeed?.follow(toTarget: userFeed!.feedId, activityCopyLimit: 1) { result in
    print(result)
}

// Read timeline and user's post appears in the feed:
timelineFeed?.get(pagination: .limit(10)) { result in
    let response = try! result.get()
    print(response.results)
}

// Remove an activity by referencing it's foreignId
userFeed?.remove(foreignId: "picture:10") { result in
    print(result)
}
```

<b>More API examples [here](https://github.com/GetStream/stream-swift/wiki)</b>

## Copyright and License Information

Copyright (c) 2016-2018 Stream.io Inc, and individual contributors. All rights reserved.

See the file "[LICENSE](https://github.com/GetStream/stream-swift/blob/master/LICENSE)" for information on the history of this software, terms & conditions for usage, and a DISCLAIMER OF ALL WARRANTIES.
