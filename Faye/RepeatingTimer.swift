//
//  RepeatingTimer.swift
//  Alamofire
//
//  Created by Alexey Bukhtin on 22/02/2019.
//

import Foundation

public final class RepeatingTimer {
    private enum State {
        case suspended
        case resumed
    }
    
    public typealias EventHandler = () -> Void
    
    let timeInterval: DispatchTimeInterval
    private let queue: DispatchQueue?
    public var eventHandler: EventHandler?
    private var state: State = .suspended
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        timer.setEventHandler { [weak self] in self?.eventHandler?() }
        return timer
    }()
    
    public init(timeInterval: DispatchTimeInterval, queue: DispatchQueue? = nil, eventHandler: EventHandler? = nil) {
        self.timeInterval = timeInterval
        self.queue = queue
        self.eventHandler = eventHandler
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /// If the timer is suspended, calling cancel without resuming
        /// triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
        resume()
        eventHandler = nil
    }
    
    public func resume() {
        if state == .resumed {
            return
        }
        
        state = .resumed
        timer.resume()
    }
    
    public func suspend() {
        if state == .suspended {
            return
        }
        
        state = .suspended
        timer.suspend()
    }
}
