//
//  BestTimeNetworker.swift
//  Bank23
//
//  Created by Ian Vonseggern on 1/3/18.
//  Copyright © 2018 Ian Vonseggern. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB
import AWSCore

struct BestTime {
  var time = 0
  var username: String?
  var userID = ""
  var facebookID: String?
}

public final class BestTimeNetworker {
  var bestTimes = [String: BestTime]() // Map boardID to BestTime
  
  // Returns true if the database has been successfully updated, false otherwise
  func userCompletedLevelWithTime(level: GameModel, time: Int) -> Bool {
    let boardID = String(level.hash())
    
    // If its not the best time ever we don't need to do anything
    if bestTimes[boardID] != nil && bestTimes[boardID]!.time <= time {
      return true
    }
    
    // TODO update DB conditionally
    return true
  }

  func getAllBestTimes() {
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let scanExpression = AWSDynamoDBScanExpression()
    scanExpression.limit = 250
    
    objectMapper.scan(Boards.self, expression: scanExpression).continueWith {
      (task:AWSTask<AWSDynamoDBPaginatedOutput>) -> () in
      if let error = task.error as NSError? {
        print("Unable to fetch best times. Error: \(error)")
      } else if let paginatedOutput = task.result {
        for item in paginatedOutput.items {
          let bestTimeTableInstance = item as! BestTimesTable

          if (
            bestTimeTableInstance._time != nil &&
            bestTimeTableInstance._userUUID != nil &&
            bestTimeTableInstance._boardID != nil
          ) {
            var bestTime = BestTime()
            bestTime.facebookID = bestTimeTableInstance._facebookID
            bestTime.time = bestTimeTableInstance._time as! Int
            bestTime.userID = bestTimeTableInstance._userUUID!
            bestTime.username = bestTimeTableInstance._username
            
            self.bestTimes[bestTimeTableInstance._boardID!] = bestTime
          }
        }
      }
    }
  }
}
