//: [Previous](@previous)
import Foundation
import PlaygroundSupport
import Faye
PlaygroundPage.current.needsIndefiniteExecution = true

let websocketURL = URL(string: "wss://faye.getstream.io/faye")!
let client = Client(url: websocketURL, plugins: [LoggerPlugin()])

startSync()

client.connect() { isConnected, error in
    print(isConnected, error)
    endSync(finishPlayground: true)
}

waitSync()

//: [Next](@next)
