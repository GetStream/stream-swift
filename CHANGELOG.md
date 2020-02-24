<a name="2.2.2"></a>
# [2.2.2](https://github.com/GetStream/stream-swift/releases/tag/2.2.2) - 24 Feb 2020

### 🐞 Fixed
- `ISO8601DateFormatter.Options.withFractionalSeconds` option for `ISO8601DateFormatter` causes an exception in iOS11 (fixed in iOS11.2) [#24](https://github.com/GetStream/stream-swift/pull/24)

[Changes][2.2.2]


<a name="2.2.1"></a>
# [2.2.1](https://github.com/GetStream/stream-swift/releases/tag/2.2.1) - 20 Dec 2019

### ✅ Added
- `Client.disconnect()` will disconnect from Stream and reset the current `User`.
- Public `Comment.text`

[Changes][2.2.1]


<a name="2.2.0"></a>
# [2.2.0](https://github.com/GetStream/stream-swift/releases/tag/2.2.0) - 20 Dec 2019

### 💥 Breaking Changes
The `Client` will always work as a shared instance and you can setup it without a user token:
```swift
Client.config = .init(apiKey: "<#ApiKey#>", appId: "<#AppId#>")
```
The user setup is more clear. You can easily manage user login/logout:
```swift
Client.shared.setupUser(token: token) { _ in 
    // Do all your requests from here. Reload feeds and etc.
}
```
No need to send to create a Stream user request for new users.

You can use custom User type with an additional user parameter. For example:
```swift
let myUser = MyUser(id: "123", name: "John Doe", avatarURL: avatarURL)
Client.shared.setupUser(myUser, token: token) { _ in 
    print(MyUser.current)
}
```

### ✅ Added
- Custom JSON Encoder/Decoder. You can change `JSONDecoder.default` and `JSONEncoder.default`.

### 🔄 Changed
- `ClientError.parameterInvalid(AnyKeyPath)` > `ClientError.parameterInvalid(String)`

### 🐞 Fixed
- Xcode 10 support
- Cached `ISO8601DateFormatter`.

[Changes][2.2.0]


<a name="2.1.0"></a>
# [2.1.0](https://github.com/GetStream/stream-swift/releases/tag/2.1.0) - 12 Nov 2019

### Added
- `MissingReference` a wrapper for activities, users, reactions and collection objects with missing references.
- `Missable` protocol to implement a placeholder for missed objects.

[Changes][2.1.0]


<a name="2.0.1"></a>
# [2.0.1](https://github.com/GetStream/stream-swift/releases/tag/2.0.1) - 12 Nov 2019

Added more logs.

[Changes][2.0.1]


<a name="2.0.0"></a>
# [2.0.0](https://github.com/GetStream/stream-swift/releases/tag/2.0.0) - 10 Sep 2019

Support for Swift 5

[Changes][2.0.0]


<a name="1.2.2"></a>
# [1.2.2](https://github.com/GetStream/stream-swift/releases/tag/1.2.2) - 16 Jul 2019

- Fixed adding an enriched activity to a feed.
- Made `ClientError` properties are public.
- Added `originFeedId` to the `Activity`.

[Changes][1.2.2]


<a name="1.2.0"></a>
# [1.2.0](https://github.com/GetStream/stream-swift/releases/tag/1.2.0) - 21 Jun 2019

- Fixed the Activity endpoint with getting enriched activities by ids

[Changes][1.2.0]


<a name="1.1.9"></a>
# [1.1.9](https://github.com/GetStream/stream-swift/releases/tag/1.1.9) - 16 Apr 2019

- The `Activity` actor now is a `User` by default.
- Added `createCurrentUser` method to simplify the client setup. 
See docs: https://github.com/GetStream/stream-swift/wiki/Quick-start

[Changes][1.1.9]


<a name="1.1.8"></a>
# [1.1.8](https://github.com/GetStream/stream-swift/releases/tag/1.1.8) - 16 Apr 2019

Fixed dependencies.

[Changes][1.1.8]


<a name="1.1.7"></a>
# [1.1.7](https://github.com/GetStream/stream-swift/releases/tag/1.1.7) - 16 Apr 2019

Fixed dependencies.

[Changes][1.1.7]


<a name="1.1.6"></a>
# [1.1.6](https://github.com/GetStream/stream-swift/releases/tag/1.1.6) - 15 Mar 2019

- Added the `current` user property to the `UserProtocol`.
- Extracted the `original` property from `Reactionable` to `OriginalRepresentable` protocol.
- Removed unused property `target` from `ActivityProtocol`.


[Changes][1.1.6]


<a name="1.1.5"></a>
# [1.1.5](https://github.com/GetStream/stream-swift/releases/tag/1.1.5) - 05 Mar 2019

- Added a `Bundle` extension for Stream setup.
- Extended `Reactionable` with `original` object.
- Extended `Reactionable` with user own reactions convenient functions.
- Added to `FeedId` a new constructor for the current user `.init?(feedSlug: String)`.
- Added `originFeedId` for the `Activity`.
- Added associated types for `ReactionProtocol`.

[Changes][1.1.5]


<a name="1.1.4"></a>
# [1.1.4](https://github.com/GetStream/stream-swift/releases/tag/1.1.4) - 28 Feb 2019

- Added a convenient function `getCurrentUser` to the `Client`. 

[Changes][1.1.4]


<a name="1.1.3"></a>
# [1.1.3](https://github.com/GetStream/stream-swift/releases/tag/1.1.3) - 26 Feb 2019

### Added
- A shared instance for the `Client`. Just setup `Client.config` before using it.
```
// Setup a shared Stream client before using it.
Client.config = .init(apiKey: "API_KEY", appId: "APP_ID", token: "TOKEN")

// Create Chris's user feed.
let chrisFeed = Client.shared.flatFeed(feedSlug: "user", userId: "chris")
```
- A new property `feedGroupId` for the `Activity`.
- New properties `unseenCount` and `unreadCount` to the `Response`.

### Fixes
- Hided logs from the Faye client.
- Subscriptions for updates to keeping web socket connection.
- Fixed a feed subscription callbackQueue.

[Changes][1.1.3]


<a name="1.1.1"></a>
# [1.1.1](https://github.com/GetStream/stream-swift/releases/tag/1.1.1) - 14 Feb 2019

- New reactions will add at the beginning of the activity reactions.
- Added user own reactions for a reaction in requests of getting reactions by `activityId`.
- Added a new type `ReactionExtraData ` as an example of reaction extra data usage with a different content type.
- Added functions to Reaction for child reaction managing.

[Changes][1.1.1]


<a name="1.1.0"></a>
# [1.1.0](https://github.com/GetStream/stream-swift/releases/tag/1.1.0) - 07 Feb 2019

- Reaction type require a `User` type.
- Added the `user` property for `Reaction` and removed the `userId` property.
- Activity type require a `ReactionType` type (`ReactionProtocol`).
- `ReactionNoExtraData` renamed to `EmptyReactionExtraData`.
- Added `DefaultReaction` = `Reaction<EmptyReactionExtraData, User>`
- Updated `Activity` = `EnrichedActivity<String, String, String, DefaultReaction>`


[Changes][1.1.0]


<a name="1.0.4"></a>
# [1.0.4](https://github.com/GetStream/stream-swift/releases/tag/1.0.4) - 23 Jan 2019

- `Client.callbackQueue` now is `DispatchQueue.main` by default and would be used after parsing for completion blocks.
- `Feed` has own `callbackQueue` and by default it used `Client.callbackQueue`.
- `ActivityProtocol` extended with helper functions `addOwnReaction` and `deleteOwnReaction` ([docs](https://getstream.github.io/stream-swift/Protocols/ActivityProtocol.html#/Own%20reactions)).
- Reactions and `User` are equitable now.
- `ActivityProtocol` is `Enrichable` now. It's very useful if needs to use an activity as an enrichable object. For example in repost, where `object` could be the original activity.

[Changes][1.0.4]


<a name="1.0.3"></a>
# [1.0.3](https://github.com/GetStream/stream-swift/releases/tag/1.0.3) - 14 Jan 2019

- Response for items with `next: Pagination` and `duration`.
- Fixed SPM
- Docs generated: https://getstream.github.io/stream-swift/

[Changes][1.0.3]


<a name="1.0.2"></a>
# [1.0.2](https://github.com/GetStream/stream-swift/releases/tag/1.0.2) - 11 Jan 2019



[Changes][1.0.2]


<a name="1.0.1"></a>
# [1.0.1](https://github.com/GetStream/stream-swift/releases/tag/1.0.1) - 11 Jan 2019



[Changes][1.0.1]


<a name="1.0.0"></a>
# [1.0.0](https://github.com/GetStream/stream-swift/releases/tag/1.0.0) - 11 Jan 2019

The first public version.

[Changes][1.0.0]

[2.2.2]: https://github.com/GetStream/stream-swift/compare/2.2.1...2.2.2
[2.2.1]: https://github.com/GetStream/stream-swift/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/GetStream/stream-swift/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/GetStream/stream-swift/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/GetStream/stream-swift/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/GetStream/stream-swift/compare/1.2.2...2.0.0
[1.2.2]: https://github.com/GetStream/stream-swift/compare/1.2.0...1.2.2
[1.2.0]: https://github.com/GetStream/stream-swift/compare/1.1.9...1.2.0
[1.1.9]: https://github.com/GetStream/stream-swift/compare/1.1.8...1.1.9
[1.1.8]: https://github.com/GetStream/stream-swift/compare/1.1.7...1.1.8
[1.1.7]: https://github.com/GetStream/stream-swift/compare/1.1.6...1.1.7
[1.1.6]: https://github.com/GetStream/stream-swift/compare/1.1.5...1.1.6
[1.1.5]: https://github.com/GetStream/stream-swift/compare/1.1.4...1.1.5
[1.1.4]: https://github.com/GetStream/stream-swift/compare/1.1.3...1.1.4
[1.1.3]: https://github.com/GetStream/stream-swift/compare/1.1.1...1.1.3
[1.1.1]: https://github.com/GetStream/stream-swift/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/GetStream/stream-swift/compare/1.0.4...1.1.0
[1.0.4]: https://github.com/GetStream/stream-swift/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/GetStream/stream-swift/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/GetStream/stream-swift/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/GetStream/stream-swift/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/GetStream/stream-swift/tree/1.0.0

 <!-- Generated by changelog-from-release -->
