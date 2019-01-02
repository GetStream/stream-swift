# GetStream

## Quick start

```swift
// Setup Stream client.
let client = Client(apiKey: "<#ApiKey#>", appId: "<#AppId#>", token: <#Token#>)

// Create Chris's user feed.
let chrisFeed = client.flatFeed(feedSlug: "user", userId: "chris")

// Create an Activity. You can make own Activity class or struct with custom properties.
let activity = Activity(actor: "chris", verb: "add", object: "picture:10", foreignId: "picture:10")

chrisFeed.add(activity) { result in
    // A result of the adding of the activity.
    print(result)
}

// Create a following relationship between Jack's "timeline" feed and Chris' "user" feed:
let jackFeed = client.flatFeed(feedSlug: "timeline", userId: "jack")

jackFeed.follow(to: chrisFeed.feedId, activityCopyLimit: 1) { result in
    print(result)
}

// Read Jack's timeline and Chris' post appears in the feed:
jackFeed.get(pagination: .limit(10)) { result in
    let activities = try! result.dematerialize()
    print(activities)
}

// Remove an activity by referencing it's foreignId
chrisFeed.remove(foreignId: "picture:10") { result in
    print(result)
}
```

## Activities

### Adding Activities
```swift
let user1 = client.flatFeed(feedSlug: "user", userId: "1")
let activity = Activity(actor: "User:1", verb: "pin", object: "Place:42")

user1.add(activity) { result in
    if case .success(let activity) = result {
        // Added activity
        print(activity.id)
    }
}
```

### Custom fields
```swift
// Create a custom Activity class.
final class Activity: GetStream.Activity {
    private enum CodingKeys: String, CodingKey {
        case course
        case participants
        case startDate = "started_at"
    }
    
    var course: Course
    var participants: [String] = []
    var startDate: Date = Date()
    
    init(actor: String, 
         verb: String, 
         object: String, 
         course: Course,
         participants: [String],
         startDate: Date = Date()) {
        super.init(actor: actor, verb: verb, object: object)
        self.course = course
        self.participants = participants
        self.startDate = startDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        course = try container.decode(Course.self, forKey: .course)
        participants = try container.decode([String].self, forKey: .participants)
        startDate = try container.decode(Date.self, forKey: .startDate)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(course, forKey: .course)
        try container.encode(participants, forKey: .participants)
        try container.encode(startDate, forKey: .startDate)
        try super.encode(to: encoder)
    }
}

struct Course: Codable {
    let name: String
    let distance: Float
}

let exercise = Activity(actor: "User:1",
                        verb: "run", 
                        object: "Exercise:42", 
                        course: Course(name: "Golden Gate Park", distance: 10), 
                        participants: ["Thierry", "Tommaso"])

user1.add(exercise) { result in
    print(result)
}
```

### Retrieving Activities
```swift
// Get activities from 5 to 10.
user1.get(pagination: .limit(5) + .offset(5)) { result in /* ... */ }

// Get the 5 activities added after lastActivity.
user1.get(pagination: .limit(5) + .lessThan(lastActivity.id)) { result in /* ... */ }

// Get the 5 activities added before lastActivity.
user1.get(pagination: .limit(5) + .greaterThan(lastActivity.id)) { result in /* ... */ }

// Get activities sorted by rank (Ranked Feeds Enabled).
user1.get(pagination: .limit(5), ranking: "popularity") { result in /* ... */ }

// Get the 5 activities and enrich them with reactions and collections.
user1.get(enrich: true, pagination: .limit(5), includeReactions: [.own, .latest, .counts]) { result in /* ... */ }
```

### Removing Activities
```swift
// Remove an activity by its id.
user1.remove(activityId: UUID(uuidString: "50539e71-d6bf-422d-ad21-c8717df0c325"))

// Remove activities foreign_id 'run:1'.
user1.remove(foreignId: "run:1")
```

### Updating Activities
```swift
// Create a custom activity with a `popularity` property.
let activity = Activity(actor: "1", verb: "like", object: "3", popularity: 100)

user1.add(activity) { _ in
    activity.popularity = 10
    client.update(activities: [activity]) { result in /* ... */ }
}
```

### Activity partial update
```swift
client.updateActivity(typeOf: ProductActivity.self,
                      setProperties: ["product.price": 19.99, 
                                      "shares": ["facebook": "...", "twitter": "..."]],
                      unsetProperties: ["daily_likes", "popularity"],
                      activityId: UUID(uuidString: "54a60c1e-4ee3-494b-a1e3-50c06acb5ed4")!) { result in /* ... */ }

client.updateActivity(typeOf: ProductActivity.self,
                      setProperties: [...],
                      unsetProperties: [...],
                      foreignId: "product:123",
                      time: "2016-11-10T13:20:00.000000".streamDate!) { result in /* ... */ }
```

### Uniqueness & Foreign ID
```swift
let firstActivity = Activity(actor: "1", verb: "add", object: "1", foreignId: "activity_1", time: Date())

// Add activity to activity feed:
var firstActivityId: UUID?
user1.add(firstActivity) { result in
    let addedActivity = try! result.dematerialize()
    firstActivityId = addedActivity.id 
}

let secondActivity = Activity(actor: "1", verb: "add", object: "1", foreignId: "activity_2", time: Date())

var secondActivityId: UUID?
user1.add(secondActivity) { result in
    let addedActivity = try! result.dematerialize()
    secondActivityId = addedActivity.id 
}

/// The unique combination of `foreignId` and `time` ensure that both
/// activities are unique and therefore the `firstActivityId != secondActivityId`
```

## Follows

### Following Feeds
```swift
let timelineFeed1 = client.flatFeed(feedSlug: "timeline", userId: "timeline_feed_1"))

// `timeline:timeline_feed_1` follows `user:user_42`:
timelineFeed1.follow(to: FeedId(feedSlug: "user", userId: "user_42")) { result in /* ... */ }

// Follow feed without copying the activities:
timelineFeed1.follow(to: FeedId(feedSlug: "user", userId: "user_42"), activityCopyLimit: 0) { result in /* ... */ }
```

### Unfollowing Feeds
```swift
// Stop following feed user_42 - purging history:
timelineFeed1.unfollow(from: FeedId(feedSlug: "user", userId: "user_42")) { result in /* ... */ }

// Stop following feed user_42 but keep history of activities:
timelineFeed1.unfollow(from: FeedId(feedSlug: "user", userId: "user_42"), keepHistory: true) { result in /* ... */ }
```

### Reading Feed Followers
```swift
// List followers
user1.followers(offset: 10, limit: 10) { result in /* ... */ }
```

### Reading Followed Feeds
```swift
// Retrieve last 10 feeds followed by user_feed_1
user1.following(limit: 10) { result in /* ... */ }

// Retrieve 10 feeds followed by user_feed_1 starting from the 11th
user1.following(offset: 10, limit: 10) { result in /* ... */ }

// Check if user1 follows specific feeds
user1.following(filter: [FeedId(feedSlug: "user", userId: "42"),
                         FeedId(feedSlug: "user", userId: "43")], limit: 2) { result in /* ... */ }
```

## Feed Groups

### Notification Feeds
```swift
// Mark all activities in the feed as seen:
notificationFeed.get(markOption: .seenAll) { result in /* ... */ }

// Mark some activities as read via specific Activity Group Ids:
notificationFeed.get(markOption: .read(["activityGroupIdOne", "activityGroupIdTwo"]) { result in /* ... */ }
```

## Ranking

### Custom Ranking
```swift
// Create a custom Activity class with `popularity` property.
final class PopularityActivity: Activity {
    private enum CodingKeys: String, CodingKey {
        case popularity
    }

    var popularity: Int

    init(actor: String, verb: String, object: String, popularity: Int) {
        super.init(actor: actor, verb: verb, object: object)
        self.popularity = popularity
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        popularity = try container.decode(Int.self, forKey: .popularity)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(popularity, forKey: .popularity)
        try super.encode(to: encoder)
    }
}

// Add Activity.
let activity = PopularityActivity(actor: "User:2", verb: "pin", object: "Place:42", popularity: 5)
user1.add(activity) { result in /* ... */ }
```

### Retrieving Activities
```swift
// Get activities sorted by the ranking method labelled 'activity_popularity' (Ranked Feeds Enabled):
user1.get(ranking: "activity_popularity")
```

## Concepts

### Targeting Using the "TO" Field
#### Use Case: Mentions
```swift
// Add the activity to Eric's feed and to Jessica's notification feed:
let activity = TweetActivity(actor: "user:Eric", 
                             verb: "tweet", 
                             object: "tweet:id",
                             feedIds: [FeedId(feedSlug: "notification", userId: "Jessica")],
                             message: "@Jessica check out getstream.io it's awesome!")

userFeed1.add(activity) { result in /* ... */ }
// In production use user ids, not their usernames.
```

#### Use Case: Organizations & Topics
```swift
// The TO field ensures the activity is send to the player, match and team feed
let activity = MatchActivity(actor: "Player:Suarez",
                             verb: "foul",
                             object: "Player:Ramos",
                             match: Match(name: "El Clasico", id: 10),
                             feedIds: [FeedId(feedSlug: "team", userId: "barcelona"),
                                       FeedId(feedSlug: "match", userId: "1")]) 

playerFeed1.add(activity) { result in /* ... */ }
```

## Advanced

### Retrieving activities by ID
```swift
// retrieve two activities by ID:
client.get(typeOf: Activity.self, activityIds: [UUID(uuidString: "01b3c1dd-e7ab-4649-b5b3-b4371d8f7045")!,
                                                UUID(uuidString: "ed2837a6-0a3b-4679-adc1-778a1704852d")!]) { result in
    /* ... */ 
}

// retrieve an activity by foreign ID and time
client.get(typeOf: Activity.self, 
           foreignIds: ["like:1", "post:2"],
           times: ["2018-07-08T14:09:36.000000".streamDate!, "2018-07-09T20:30:40.000000".streamDate!]) { result in
    /* ... */ 
}
```

## Web&Mobile

### Realtime updates
```swift
let notificationFeed = client.flatFeed(feedSlug: "notification", userId: "1")

var subscription: Subscription? = notificationFeed.subscribe(typeOf: Activity.self) { result in /* ... */ }

// Keep `subscription` object until you need realtime updates and then to unsubscribe set it to nil:
subscription = nil
```

## Reactions

### Add reactions
```swift
// add a like reaction to the activity with id activityId
client.add(reactionTo: activityId, kindOf: "like") { result in /* ... */ }

// adds a comment reaction to the activity with id activityId
client.add(reactionTo: activityId, kindOf: "comment", extraData: Comment(text: "awesome post!")) { result in /* ... */ }
```

Here's a complete example:
```swift
// we recommend to add reaction kinds to the extention of the `ReactionKind` to avoid typos
extension ReactionKind {
    static let like = "like"
    static let comment = "comment"
}

// first let's read current user's timeline feed and pick one activity
client.flatFeed(feedSlug: "timeline", userId: "mike").get { result in
    if let activities = try? result.dematerialize(), let activity = activities.first, let activityId = activity.id {
        // then let's add a like reaction to that activity
        client.add(reactionTo: activityId, kindOf: .like) { result in
            print(result) // will print a reaction object in the result.
        }
    }
}
```

### Notify other feeds
```swift
// adds a comment reaction to the activity and notifies Thierry's notification feed
client.add(reactionTo: activityId, 
           kindOf: "comment", 
           extraData: Comment(text: "awesome post!"),
           targetsFeedIds: [FeedId(feedSlug: "notification", userId: "thierry")]) { result in /* ... */ }
```

### Read feeds with reactions
```swift
// read bob's timeline and include most recent reactions to all activities and their total count
client.flatFeed(feedSlug: "timeline", userId: "bob")
    .get(includeReactions: [.latest, .counts]) { result in /* ... */ }
    
// read bob's timeline and include most recent reactions to all activities and her own reactions
client.flatFeed(feedSlug: "timeline", userId: "bob")
    .get(includeReactions: [.own, .latest, .counts]) { result in /* ... */ }
```

### Retrieving reactions
```swift
// retrieve all kind of reactions for an activity
client.reactions(forActivityId: UUID(uuidString: "ed2837a6-0a3b-4679-adc1-778a1704852d")!) { result in /* ... */ }

// retrieve first 10 likes for an activity
client.reactions(forActivityId: UUID(uuidString: "ed2837a6-0a3b-4679-adc1-778a1704852d")!,
                 kindOf: "like",
                 pagination: .limit(10)) { result in /* ... */ }

// retrieve the next 10 likes using the id_lt param
client.reactions(forActivityId: UUID(uuidString: "ed2837a6-0a3b-4679-adc1-778a1704852d")!,
                 kindOf: "like",
                 pagination: .lessThan("e561de8f-00f1-11e4-b400-0cc47a024be0")) { result in /* ... */ }
```

### Child reactions
```swift
// add a like reaction to the previously created comment
client.add(reactionToParentReaction: commentReaction, kindOf: "like") { result in /* ... */ }
```

### Updating Reactions
```swift
client.update(reactionId: reactionId, extraData: Comment(text: "love it!")) { result in /* ... */ }
```

### Removing Reactions
```swift
client.delete(reactionId: reactionId) { result in /* ... */ }
```

## Collections

### Adding collection entries
```swift
// create a new collection object type with custom properties
final class Food: CollectionObject {
    private enum CodingKeys: String, CodingKey {
        case name
        case rating
    }
    
    var name: String
    var rating: Float
    
    init(name: String, rating: Float, id: String? = nil) {
        self.name = name
        self.rating = rating
        // For example, set the collection name here for all instances of Food.
        super.init(collectionName: "food", id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        name = try container.decode(String.self, forKey: .name)
        rating = try container.decode(Float.self, forKey: .rating)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try container.encode(rating, forKey: .rating)
        try super.encode(to: encoder)
    }
}


client.add(collectionObject: Food(name: "Cheese Burger", rating: 4, id: "cheese-burger")) { result in /* ... */ }

// if you don't have an id on your side, just use nil as the ID and Stream will generate a unique ID
client.add(collectionObject: Food(name: "Cheese Burger", rating: 4)) { result in /* ... */ }
```

### Retrieving collection entries
```swift
client.get(typeOf: Food.self, collectionName: "food", collectionObjectId: "cheese-burger") { result in /* ... */ }
```

### Deleting collection entries
```swift
client.delete(collectionName: "food", collectionObjectId: "cheese-burger") { result in /* ... */ }
```

### Updating collection entries
```swift
client.update(collectionObject: Food(name: "Cheese Burger", rating: 1, id: "cheese-burger")) { result in /* ... */ }
```

### Enrichment of collection entries
```swift
// first we add our object to the food collection
let cheeseBurger = Food(name: "Cheese Burger", rating: 4, id: "cheese-burger")

// setup an enriched activity type
typealias UserFoodActivity = EnrichedActivity<User, Food, String>

client.add(collectionObject: cheeseBurger) { _ in
    // the object returned by .add can be embedded directly inside of an activity
    userFeed.add(UserFoodActivity(actor: client.currentUser!, verb: 'grill', object: cheeseBurger)) { _ in
        // if we now read the feed, the activity we just added will include the entire full object
        userFeed.get(typeOf: UserFoodActivity.self) { result in
            let activities = try! result.dematerialize()
            
            // we can then update the object and Stream will propagate the change to all activities
            cheeseBurger.name = "Amazing Cheese Burger"
            client.update(collectionObject: cheeseBurger) { result in /* ... */ }
        }
    }
}
```

### References
```swift
// First create a collection entry with upsert api
let cheeseBurger = Food(name: "Cheese Burger", rating: 4, id: "cheese-burger")

client.add(collectionObject: cheeseBurger) { _ in
    // Then create a user
    let user = User(id: "john-doe")
    client.create(user: user) { _ in
        // Since we know their IDs we can create references to both without reading from APIs
        // The `CollectionObjectProtocol` and `UserProtocol` conformed to the `Enrichable` protocol.
        let cheeseBurgerRef = cheeseBurger.referenceId
        let johnDoeRef = user.referenceId
        
        client.flatFeed(feedSlug: "user", userId: "john")
              .add(Activity(actor: johnDoeRef, verb: "eat", object: cheeseBurgerRef)) { result in /* ... */ }
    }
}
```

## Users

```swift
let client = Client(apiKey: "<#ApiKey#>", appId: "<#AppId#>", token: <#Token#>)
let user = User(id: "john-doe")

client.create(user: user) { result in
    if let createdUser = try? result.dematerialize() {
        client.currentUser = createdUser
    }
}
```

### Adding users
```swift
// create a new user, if the user already exist an error is returned
client.create(user: User(id: "john-doe"), getOrCreate: false) { result in /* ... */ }

// get or create a new user, if the user already exist the user is returned
client.create(user: User(id: "john-doe"), getOrCreate: true) { result in /* ... */ }
```

### Retrieving users
```swift
client.get(userId: "123") { result in /* ... */ }
```

### Removing users
```swift
client.delete(userId: "123") { result in /* ... */ }
```

### Updating users
```swift
client.update(user: User(id: "john-doe")) { result in /* ... */ }
```

## Enrichment

### Collections and Users
```swift
let userFeed = client.flatFeed(feedSlug: "user", userId: "jack")

// setup an enriched activity type with the `Post` as the subclass of `CollectionObject`
typealias UserPostActivity = EnrichedActivity<User, Post, String>

client.create(user: User(id: "jack")) { result in
    client.currentUser = try! result.dematerialize()
    
    client.add(collectionObject: Post(text: "...", id: "42-ways-to-improve-your-feed")) { _ in
        let post = try! result.dematerialize()
        userFeed.add(UserPostActivity(actor: client.currentUser!, verb: "post", object: post)) { _ in
            // if we now read Jack's feed we will get automatically the enriched data
            userFeed.get(typeOf: UserPostActivity.self) { result in 
                print(result)
                
                // we can also update Jack's post and get the new version 
                // automatically propagated to his feed and its followers
                post.text = "new version of the post"
                client.update(collectionObject: post) { _ in
                    userFeed.get(typeOf: UserPostActivity.self) { result in 
                        // jack's feed now has the new version of the data
                        print(result)
                    }
                }
            }
        }
    }
}
```

## Files and Images

### Upload
```swift
// uploading an `UIImage` as PNG data
client.upload(image: File(name: "image.png", pngImage: image)) { result in /* ... */ }

// uploading an `UIImage` as JPEG data
client.upload(image: File(name: "image.jpg", jpegImage: image, compressionQuality: 0.9)) { result in /* ... */ }

// uploading a file
client.upload(file: File(name: "file", data: fileData)) { result in /* ... */ }
```

### Delete
```swift
// deleting an image using the url returned by the APIs
client.delete(imageURL: imageURL) { result in /* ... */ }

// deleting a file using the url returned by the APIs
client.delete(fileURL: fileURL) { result in /* ... */ }
```

### Process images
```swift
// create a 50x50 thumbnail and crop from center.
// `ImageProcess` has the `crop` parameter as `.center` by default.
client.resizeImage(imageProcess: ImageProcess(url: url, resize: .crop, width: 50, height: 50)) { result in /* ... */ }

// create a 50x50 thumbnail using clipping (keeps aspect ratio).
// `ImageProcess` has the `resize` parameter as `.clip` by default.
client.resizeImage(imageProcess: ImageProcess(url: url, width: 50, height: 50)) { result in /* ... */ }
```

## Open Graph

### Scrape Open Graph Metadata from URLs
```swift
client.og(url: URL(string: "https://www.imdb.com/title/tt0117500/")!) { result in
    // An `OGResponse` object would be in the result.
    print(result)  
}
```
