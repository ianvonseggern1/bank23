//
//  Timer.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/26/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

// Timer counts up in seconds, and supports pausing
public final class Timer {
  // Total of all prior splits
  var timeElapsed = 0
  
  // Start of current split
  var splitStart: NSDate?
  
  // Starts or restarts this Timer. To reset simply instantiate a new timer.
  func start() {
    splitStart = NSDate()
  }
  
  func pause() {
    timeElapsed += self.timeSinceSplit()
    splitStart = nil
  }
  
  func time() -> Int {
    return timeElapsed + self.timeSinceSplit()
  }
  
  private func timeSinceSplit() -> Int {
    return splitStart != nil ? Int(ceil(-1 * splitStart!.timeIntervalSinceNow)) : 0
  }
}
