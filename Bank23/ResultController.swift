//
//  MoveNetworker.swift
//  Bank23
//
//  Created by Ian Vonseggern on 4/6/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB
import AWSCore

// Seperates entries in the string
private let LEVELS_BEAT_STRING_SEPERATOR = "-"
// Seperates key (board hash) from value (completion time in seconds)
private let LEVELS_BEAT_TIME_SEPERATOR: Character = ":"
private let LEVELS_BEAT_USER_DEFAULTS_KEY = "Bank23LevelsBeat"

// This class is responsible for recording the results when a user beats or
// restarts a level both locally and to the database
public final class ResultController
{
  var levelsBeat = [String: Int]()
  
  public init() {
    let levelsBeatString = UserDefaults.standard.object(forKey: LEVELS_BEAT_USER_DEFAULTS_KEY) as? String

    if levelsBeatString == nil {
      levelsBeat = [:]
    } else {
      let stringArray = levelsBeatString!.components(separatedBy: LEVELS_BEAT_STRING_SEPERATOR)
      for levelString in stringArray {
        let indexOfSeperator = levelString.index(of: LEVELS_BEAT_TIME_SEPERATOR)
        if indexOfSeperator == nil {
          // This level was beaten before we traked time. We really don't need to keep this
          // case as it only affects me.
          levelsBeat[levelString] = Int(INT_MAX)
        } else {
          let key = String(levelString[..<indexOfSeperator!])
          let indexOfTime = levelString.index(indexOfSeperator!, offsetBy: 1)
          let time = Int(levelString[indexOfTime...])
          levelsBeat[key] = time
        }
      }
    }
  }
  
  static func writeResultToDatabase(level: GameModel, // Initial model, before moves are made
                                    uniquePlayId: String,
                                    victory: Bool,
                                    notEnoughPiecesLeft: Bool,
                                    moves: [Direction],
                                    initialShuffledPieces: [Piece],
                                    elapsedTime: Int) {
    let resultToAdd = ResultsTable()
    resultToAdd?._boardHash = String(level.hash())
    resultToAdd?._boardName = level._levelName
    resultToAdd?._playID = uniquePlayId
    resultToAdd?._won = victory as NSNumber
    resultToAdd?._notEnoughPieces = notEnoughPiecesLeft as NSNumber
    resultToAdd?._moveCount = moves.count as NSNumber
    resultToAdd?._moves = moves.map({ Direction.toString($0) })
    if initialShuffledPieces.count > 0 {
      resultToAdd?._shuffledPieces = initialShuffledPieces.map({ $0.shortName() })
    }
    resultToAdd?._timeStamp = NSDate().timeIntervalSince1970 as NSNumber
    resultToAdd?._userUUID = UserController.getUserId()
    if let username = UserController.getUsername() {
      resultToAdd?._username = username
    }
    resultToAdd?._elapsedTime = elapsedTime as NSNumber
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    objectMapper.save(resultToAdd!, completionHandler: {(error: Error?) -> Void in
      if let error = error {
        print("Amazon DynamoDB Error - saving result: \(error)")
        return
      }
      print("Result recorded.")
    })
  }

  // Returns true iff this is the fastest time yet
  func userBeatlevel(level: GameModel, elapsedTime: Int) -> Bool {
    let levelHash = String(level.hash())
    // If this isn't the fastest time we don't need to update anything
    if levelsBeat[levelHash] != nil && levelsBeat[levelHash]! <= elapsedTime {
      return false
    }
    
    // Update the dictionary
    levelsBeat[levelHash] = elapsedTime
    
    // Update the user defaults, first construct a new set of strings for all beaten
    // levels
    var levelsBeatStrings = [String]()
    for levelKey in levelsBeat.keys {
      let levelTime = levelsBeat[levelKey]!
      levelsBeatStrings.append(
        levelKey + String(LEVELS_BEAT_TIME_SEPERATOR) + String(describing: levelTime)
      )
    }
    let userDefaults = UserDefaults.standard
    userDefaults.set(levelsBeatStrings.joined(separator: LEVELS_BEAT_STRING_SEPERATOR),
                     forKey: LEVELS_BEAT_USER_DEFAULTS_KEY)
    userDefaults.synchronize()
    
    return true
  }

  func levelBestTime(_ model: GameModel) -> Int? {
    return levelsBeat[String(model.hash())]
  }
}
