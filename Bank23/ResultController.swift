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

private let LEVELS_BEAT_STRING_SEPERATOR = "-"
private let LEVELS_BEAT_USER_DEFAULTS_KEY = "Bank23LevelsBeat"

// This class is responsible for recording the results when a user beats or
// restarts a level both locally and to the database
public final class ResultController
{
  var levelsBeat: [String]
  
  public init() {
    let levelsBeatString = UserDefaults.standard.object(forKey: LEVELS_BEAT_USER_DEFAULTS_KEY) as? String

    if levelsBeatString == nil {
      levelsBeat = []
    } else {
      levelsBeat = levelsBeatString!.components(separatedBy: LEVELS_BEAT_STRING_SEPERATOR)
    }
  }
  
  static func writeResultToDatabase(level: GameModel, // Initial model, before moves are made
                                    uniquePlayId: String,
                                    victory: Bool,
                                    enoughPiecesLeft: Bool,
                                    moves: [Direction],
                                    initialShuffledPieces: [Piece]) {
    let resultToAdd = ResultsTable()
    resultToAdd?._boardHash = String(level.hash())
    resultToAdd?._boardName = level._levelName
    resultToAdd?._playID = uniquePlayId
    resultToAdd?._won = victory as NSNumber
    resultToAdd?._notEnoughPieces = enoughPiecesLeft as NSNumber
    resultToAdd?._moveCount = moves.count as NSNumber
    resultToAdd?._moves = moves.map({ Direction.toString($0) })
    resultToAdd?._shuffledPieces = initialShuffledPieces.map({ $0.shortName() })
    
    resultToAdd?._timeStamp = NSDate().timeIntervalSince1970 as NSNumber
    resultToAdd?._userUUID = UserController.getUserId()
    resultToAdd?._username = UserController.getUsername()
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    objectMapper.save(resultToAdd!, completionHandler: {(error: Error?) -> Void in
      if let error = error {
        print("Amazon DynamoDB Error - saving result: \(error)")
        return
      }
      print("Result recorded.")
    })
  }

  func userBeatlevel(level: GameModel) {
    let levelHash = String(level.hash())
    if levelsBeat.contains(levelHash) {
      return
    }
    
    levelsBeat.append(levelHash)
    
    let userDefaults = UserDefaults.standard
    userDefaults.set(levelsBeat.joined(separator: LEVELS_BEAT_STRING_SEPERATOR),
                     forKey: LEVELS_BEAT_USER_DEFAULTS_KEY)
    userDefaults.synchronize()
  }
  
  func getAllLevelsBeaten() -> Set<String> {
    return Set(levelsBeat)
  }
}
