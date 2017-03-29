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

public final class LevelNetworker
{
  static func writeLevelToDatabase(level: GameModel) throws {
    if !verifyBoardIsValid(level._board) || !verifyInitialPieceListIsValid(level._pieces) {
      throw LevelNetworkerError.invalidBoardOrInitialPieces
    }

    let objectMapper = AWSDynamoDBObjectMapper.default()
    
    let boardString = level._board.toString()
    let initialPiecesString = level.pieceListToString()
    
    let itemToCreate = Boards()
    itemToCreate?._boardId = String(boardString.appending(initialPiecesString).hash)
    itemToCreate?._boardName = level._levelName
    itemToCreate?._board = boardString
    itemToCreate?._pieces = initialPiecesString

    objectMapper.save(itemToCreate!, completionHandler: {(error: Error?) -> Void in
      if let error = error {
        print("Amazon DynamoDB Save Error: \(error)")
        return
      }
      print("Item saved.")
    })
  }
  
  static func getAllBoardsFromDatabase(boardCallback: @escaping (GameModel) -> Void) {
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let scanExpression = AWSDynamoDBScanExpression()
    scanExpression.limit = 250

    objectMapper.scan(Boards.self, expression: scanExpression).continueWith { (task:AWSTask<AWSDynamoDBPaginatedOutput>) -> Any? in
      if let error = task.error as? NSError {
        print("Unable to fetch boards. Error: \(error)")
      } else if let paginatedOutput = task.result {
        for b in paginatedOutput.items {
          let board = b as! Boards
          do {
            let gameModel = try GameModel(name: board._boardName!,
                                          initialPiecesString: board._pieces!,
                                          initialBoardString: board._board!)
            boardCallback(gameModel)
            print("SUCCESS! Added level \(board._boardName)")
          } catch {
            print("Unable to create game from board \(board._board) and pieces \(board._pieces)")
          }
        }
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
