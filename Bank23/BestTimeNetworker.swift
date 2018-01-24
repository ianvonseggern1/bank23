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
  
  init() {
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let scanExpression = AWSDynamoDBScanExpression()
    scanExpression.limit = 250
    
    objectMapper.scan(BestTimeTable.self, expression: scanExpression).continueWith {
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
  
  func getBestTimeFor(level: GameModel) -> BestTime? {
    let boardID = String(level.hash())
    return bestTimes[boardID]
  }
  
  // Returns true if the database has been successfully updated, false otherwise
  func userCompletedLevelWithTime(level: GameModel,
                                  elapsedTime: Int,
                                  playID: String,
                                  updateSuccesful: @escaping () -> Void,
                                  updateFailed: @escaping () -> Void) {
    let boardID = String(level.hash())
    
    let boardIDValue = AWSDynamoDBAttributeValue.init()!
    boardIDValue.s = boardID
    
    let timeStampValue = AWSDynamoDBAttributeValue.init()!
    timeStampValue.n = String(describing: NSDate().timeIntervalSince1970 as NSNumber)
    
    let bestTimeValue = AWSDynamoDBAttributeValue.init()!
    bestTimeValue.n = String(elapsedTime)
  
    let usernameValue = AWSDynamoDBAttributeValue.init()!
    let usernameString = UserController.getUsername() ?? "Unknown"
    usernameValue.s = usernameString
    
    let userUUIDValue = AWSDynamoDBAttributeValue.init()!
    let userIDString = UserController.getUserId()
    userUUIDValue.s = userIDString
    
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
        // We need to differentiate cases where someone else recently beat this time from
        // offline errors
        // This is brittle, would be good to look for better ways to do this
        if error!.localizedDescription == "The Internet connection appears to be offline." {
          print("Error saving best time for \(level._levelName) - \(error!)")
          updateFailed()
        }
      } else {
        let newBestTimes = BestTime(time: elapsedTime,
                                    username: usernameString,
                                    userID: userIDString)
        self.bestTimes[boardID] = newBestTimes
        
        updateSuccesful()
      }
    }
  }
}
