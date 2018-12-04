import PlaygroundSupport
import Foundation

/// Playground helper functions to make async function synced.
///
/// Example:
///     startSync()
///
///     URLSession.shared.dataTask(with: ...) {
///         ...
///         endSync()
///     }
///
///     waitSync()
///
///     URLSession.shared.dataTask(with: ...) {
///         ...
///         endSync()
///     }

let awaitGroup = DispatchGroup()

public func startSync() {
    awaitGroup.enter()
}

public func endSync(finishPlayground: Bool = false) {
    awaitGroup.leave()
    
    if finishPlayground {
        PlaygroundPage.current.finishExecution()
    }
}

public func waitSync() {
    awaitGroup.wait()
    awaitGroup.enter()
}
