import UIKit
import GetStream

let token = Token(secretData: "xwnkc2rdvm7bp7gn8ddzc6ngbgvskahf6v3su7qj5gp6utyu8rtek8k2vq2ssaav".data(using: .utf8)!)
let client = Client(apiKey: "3gmch3yrte9d", appId: "44738", token: token, logsEnabled: true)

let ericFeed = client.feed(feedSlug: "timeline", userId: "eric")

ericFeed.get(typeOf: Activity.self, ranking: "popular") { result in
    print(try! result.dematerialize())
}
