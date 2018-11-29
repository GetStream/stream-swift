import PlaygroundSupport
import Foundation

/// Playground helper functions to make async function synced.
///
/// Example:
///     startSync()
///     asyncRequest {
///         ...
///         endSync()
///     }
///     waitSync()
///     asyncRequest {
///         ...
///         endSync()
///     }

let awaitGroup = DispatchGroup()

public func startSync() {
    awaitGroup.enter()
}

public func endSync(_ andPlaygroundToo: Bool = false) {
    awaitGroup.leave()
    
    if andPlaygroundToo {
        PlaygroundPage.current.finishExecution()
    }
}

public func waitSync() {
    awaitGroup.wait()
    awaitGroup.enter()
}
