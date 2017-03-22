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

enum LevelNetworkerError: Error {
  case invalidBoardOrInitialPieces
}

public final class LevelNetworker
{
  static func writeLevelToDatabase(title: String, board: Board, initialPieces: [Piece]) throws {
    if !verifyBoardIsValid(board: board) || !verifyInitialPieceListIsValid(pieces: initialPieces) {
      throw LevelNetworkerError.invalidBoardOrInitialPieces
    }

    let objectMapper = AWSDynamoDBObjectMapper.default()
    
    let boardString = board.toString()
    let initialPiecesString = Piece.pieceListToString(pieces: initialPieces)
    
    let itemToCreate = Boards()
    itemToCreate?._boardId = String(boardString.appending(initialPiecesString).hash)
    itemToCreate?._boardName = title
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
  
  static func verifyBoardIsValid(board: Board) -> Bool {
    do {
      let boardCopy = try Board(fromString:board.toString())
      return board == boardCopy
    } catch {
      return false
    }
  }
  
  static func verifyInitialPieceListIsValid(pieces: [Piece]) -> Bool {
    do {
      let piecesCopy = try Piece.pieceListFromString(Piece.pieceListToString(pieces: pieces))
    
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
