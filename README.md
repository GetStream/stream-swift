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
final class Exercise: Activity {
    private enum CodingKeys: String, CodingKey {
        case locationType
        case coordinates
    }
    
    var locationType: String = "point"
    var coordinates: [Float] = []
    
    init(actor: String, verb: String, object: String, locationType: String, coordinates: [Float]) {
    super.init(actor: actor, verb: verb, object: object)
        self.locationType = locationType
        self.coordinates = coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.locationType = try container.decode(String.self, forKey: .locationType)
        self.coordinates = try container.decode([Float].self, forKey: .coordinates)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locationType, forKey: .locationType)
        try container.encode(coordinates, forKey: .coordinates)
        try super.encode(to: encoder)
    }
}

let exercise = Exercise(actor: "User:1",
                        verb: "run", 
                        object: "Exercise:42", 
                        locationType: "point", 
                        coordinates: [37.769722, -122.476944])

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

```
