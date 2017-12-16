//
//  LevelNetworker.swift
//  Bank23
//
//  Created by Ian Vonseggern on 3/21/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB
import AWSCore

enum LevelNetworkerError: Error {
  case invalidBoardOrInitialPieces
}

// Amazon Dynamo DB doesn't allow empty strings in as values (which is super silly)
// so we swap with EMPTY_STRING
private let EMPTY_STRING = "empty"

private let LEVELS_CREATED_STRING_SEPERATOR = "-"
private let LEVELS_CREATED_USER_DEFAULTS_KEY = "Bank23LevelsCreated"

public final class LevelController
{
  static func saveLocally(level: GameModel) throws {
    if !verifyBoardIsValid(level._board) || !verifyInitialPieceListIsValid(level._pieces) {
      throw LevelNetworkerError.invalidBoardOrInitialPieces
    }

    var levelsString = UserDefaults.standard.object(forKey: LEVELS_CREATED_USER_DEFAULTS_KEY) as? String
    
    if levelsString == nil {
      levelsString = level.toString()
    } else {
      levelsString = levelsString! + LEVELS_CREATED_STRING_SEPERATOR + level.toString()
    }
    
    let userDefaults = UserDefaults.standard
    userDefaults.set(levelsString, forKey: LEVELS_CREATED_USER_DEFAULTS_KEY)
    userDefaults.synchronize()
  }
  
  static func getLocalLevels() -> [GameModel] {
    let levelsString = UserDefaults.standard.object(forKey: LEVELS_CREATED_USER_DEFAULTS_KEY) as? String
    if levelsString == nil {
      return []
    }
    
    var rtn = [GameModel]()
    for levelString in levelsString!.components(separatedBy: LEVELS_CREATED_STRING_SEPERATOR) {
      do {
        rtn.append(try GameModel.fromString(levelString))
      } catch {
        print("Unable to read local level")
      }
    }
    return rtn
  }
  
  // TODO update to save to a different database table
  static func writeLevelToDatabase(level: GameModel) throws {
    if !verifyBoardIsValid(level._board) || !verifyInitialPieceListIsValid(level._pieces) {
      throw LevelNetworkerError.invalidBoardOrInitialPieces
    }

    let objectMapper = AWSDynamoDBObjectMapper.default()
    
    let itemToCreate = Boards()
    itemToCreate?._boardId = String(level.hash())
    itemToCreate?._boardName = level._levelName
    itemToCreate?._board = level._board.toString()
    
    let pieceListString = level.collapsedPieceListToString()
    itemToCreate?._pieces = pieceListString == "" ? EMPTY_STRING : pieceListString
    
    itemToCreate?._creatorId = UserController.getUserId()
    itemToCreate?._creatorName = UserController.getUsername()
    itemToCreate?._creationTime = NSDate().timeIntervalSince1970 as NSNumber
    
    objectMapper.save(itemToCreate!, completionHandler: {(error: Error?) -> Void in
      if let error = error {
        print("Amazon DynamoDB Error - saving level: \(error)")
        return
      }
      print("Level saved.")
    })
  }
  
  static func getAllBoardsFromDatabase(boardCallback: @escaping ([GameModel]) -> Void) {
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let scanExpression = AWSDynamoDBScanExpression()
    scanExpression.limit = 250
    scanExpression.filterExpression = "isActive = :val"
    scanExpression.expressionAttributeValues = [":val": true]

    objectMapper.scan(Boards.self, expression: scanExpression).continueWith { (task:AWSTask<AWSDynamoDBPaginatedOutput>) -> Any? in
      if let error = task.error as NSError? {
        print("Unable to fetch boards. Error: \(error)")
      } else if let paginatedOutput = task.result {
        
        var models = [GameModel]()
        for b in paginatedOutput.items {
          let board = b as! Boards
          do {
            let pieceListString = board._pieces! == EMPTY_STRING ? "" : board._pieces!
            let gameModel = try GameModel(name: board._boardName!,
                                          initialPiecesString: pieceListString,
                                          initialBoardString: board._board!)
            gameModel._creatorName = board._creatorName
            gameModel._explanationLabel = board._explanationLabel
            if (board._sortKey != nil) {
              gameModel._sortKey = board._sortKey!
            }
            models.append(gameModel)
            print("SUCCESS! Added level \(board._boardName ?? "") to level menu")
          } catch {
            print("Unable to create game from board \(board._board ?? "") and pieces \(board._pieces ?? "")")
          }
        }
        boardCallback(models)
      }
      return nil
    }
  }
  
  static func verifyBoardIsValid(_ board: Board) -> Bool {
    do {
      let boardCopy = try Board(fromString:board.toString())
      return board == boardCopy
    } catch {
      return false
    }
  }
  
  static func verifyInitialPieceListIsValid(_ pieces: [Piece]) -> Bool {
    do {
      let piecesCopy = try GameModel.pieceListFromString(GameModel.pieceListToString(pieces: pieces))
    
      // Check if piecesCopy and pieces are the same
      if pieces.count != piecesCopy.count {
        return false
      }
      
      if pieces.count == 0 {
        return piecesCopy.count == 0
      }
      
      for i in 1..<pieces.count {
        if pieces[i] != piecesCopy[i] {
          return false
        }
      }
      
      return true
      
    } catch {
      return false
    }
  }
}
