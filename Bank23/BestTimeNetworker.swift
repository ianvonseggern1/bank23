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
}

public final class BestTimeNetworker {
  var bestTimes = [String: BestTime]() // Map boardID to BestTime
  
  // Returns true if the database has been successfully updated, false otherwise
  func userCompletedLevelWithTime(level: GameModel, elapsedTime: Int, playID: String) {
    let boardID = String(level.hash())
    
    // If its not the best time ever we don't need to do anything
    // We also don't want to store this time if its a user created level
    if (bestTimes[boardID] != nil && bestTimes[boardID]!.time <= elapsedTime) ||
       level._levelType != LevelType.Server {
      return
    }
    
    let boardIDValue = AWSDynamoDBAttributeValue.init()!
    boardIDValue.s = boardID
    
    let timeStampValue = AWSDynamoDBAttributeValue.init()!
    timeStampValue.n = String(describing: NSDate().timeIntervalSince1970 as NSNumber)
    
    let bestTimeValue = AWSDynamoDBAttributeValue.init()!
    bestTimeValue.n = String(elapsedTime)
  
    let usernameValue = AWSDynamoDBAttributeValue.init()!
    usernameValue.s = UserController.getUsername() ?? "Unknown"
    
    let userUUIDValue = AWSDynamoDBAttributeValue.init()!
    userUUIDValue.s = UserController.getUserId()
    
    let playIDValue = AWSDynamoDBAttributeValue.init()!
    playIDValue.s = playID

    let newItem = AWSDynamoDBUpdateItemInput.init()!
    
    var updateExpression = "SET userUUID = :useruuid, "
    updateExpression += "bestTime = :bestTime, "
    updateExpression += "bestTimeTimeStamp = :bestTimeTimeStamp, "
    updateExpression += "username = :username, "
    updateExpression += "playID = :playID"
    
    newItem.updateExpression = updateExpression
    newItem.expressionAttributeValues = [":bestTime": bestTimeValue,
                                         ":useruuid": userUUIDValue,
                                         ":bestTimeTimeStamp": timeStampValue,
                                         ":username": usernameValue,
                                         ":playID": playIDValue]
    newItem.key = ["boardID": boardIDValue]
    newItem.tableName = BestTimeTable.dynamoDBTableName()
    
    // The following makes sure the DB is only updated if this is still the smallest time
    newItem.conditionExpression = "attribute_not_exists(bestTime) OR bestTime > :bestTime"
    
    AWSDynamoDB.default().updateItem(newItem) { (response, error) in
      if error != nil {
        print("Error saving best time for \(level._levelName) - \(error!)")
        // TODO offer retry UI - note this case includes the case of the conditional check failing
      } else {
        // TODO update locally
      }
    }
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
          let bestTimeTableInstance = item as! BestTimeTable

          if (
            bestTimeTableInstance._bestTime != nil &&
            bestTimeTableInstance._userUUID != nil &&
            bestTimeTableInstance._boardID != nil
          ) {
            var bestTime = BestTime()
            bestTime.time = bestTimeTableInstance._bestTime as! Int
            bestTime.userID = bestTimeTableInstance._userUUID!
            bestTime.username = bestTimeTableInstance._username
            
            self.bestTimes[bestTimeTableInstance._boardID!] = bestTime
          }
        }
      }
    }
  }
}
