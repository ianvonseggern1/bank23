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

public final class MoveNetworker
{
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
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    objectMapper.save(resultToAdd!, completionHandler: {(error: Error?) -> Void in
      if let error = error {
        print("Amazon DynamoDB Error - saving result: \(error)")
        return
      }
      print("Result recorded.")
    })
  }
}
