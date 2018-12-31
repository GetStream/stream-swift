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
