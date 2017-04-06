//
//  GameModel.swift
//  Bank23
//
//  Created by Ian Vonseggern on 3/22/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

private let PIECE_LIST_STRING_PIECE_SEPERATOR = "."

public final class GameModel {
  var _board = Board()
  var _pieces = [Piece]()
  var _levelName = ""
  
  public init() {
  }
  
  public init(name: String, initialPieces: [Piece], initialBoard: [[Piece]]) throws {
    _levelName = name
    _board = try Board(initialBoard: initialBoard)
    _pieces = GameModel.shuffle(GameModel.expandPieces(initialPieces))
  }
  
  public init(name: String, initialPiecesString: String, initialBoardString: String) throws {
    _levelName = name
    let compactPieces = try GameModel.pieceListFromString(initialPiecesString)
    _pieces = GameModel.shuffle(GameModel.expandPieces(compactPieces))
    _board = try Board(fromString: initialBoardString)
  }
  
  public func copy() -> GameModel {
    // Arrays use copy symantics so we can just create a new model
    return try! GameModel(name:self._levelName,
                          initialPieces:self._pieces,
                          initialBoard:self._board._board)
  }
  
  func hash() -> String {
    return String((_board.toString().appending(self.pieceListToString())).hash)
  }
  
  // Win iff there are no banks left
  func isWon() -> Bool {
    for column in _board._board {
      for piece in column {
        if piece.sameType(otherPiece: Piece.bank(1)) && piece.value() > 0 {
          return false
        }
      }
    }
    return true
  }
  
  // Returns true if there are not enough coins left to fill the banks
  func isLost() -> Bool {
    var remainingCoins = 0
    for piece in _pieces {
      if piece.sameType(otherPiece: Piece.coins(1)) {
        remainingCoins += piece.value()
      }
    }
    
    var coinsOnBoard = 0
    var banksOnBoard = 0
    for column in _board._board {
      for piece in column {
        if piece.sameType(otherPiece: Piece.bank(1)) {
          banksOnBoard += piece.value()
        }
        if piece.sameType(otherPiece: Piece.coins(1)) {
          coinsOnBoard += piece.value()
        }
      }
    }
    
    return coinsOnBoard + remainingCoins < banksOnBoard
  }
  
  public func pieceListToString() -> String {
    return GameModel.pieceListToString(pieces: _pieces)
  }
  
  public static func pieceListToString(pieces: [Piece]) -> String {
    return pieces.map({ (piece: Piece) -> String in
      return piece.shortName()
    }).joined(separator: PIECE_LIST_STRING_PIECE_SEPERATOR)
  }
  
  public static func pieceListFromString(_ pieceListString: String) throws -> [Piece] {
    return try pieceListString.components(separatedBy: PIECE_LIST_STRING_PIECE_SEPERATOR).map({ (pieceString) -> Piece in
      return try Piece.initFromName(pieceString)
    })
  }
  
  // We store the pieces as a single instance of each piece type, we need to expand those and
  // shuffle to set up the game
  static func expandPieces(_ compactPieceList: [Piece]) -> [Piece] {
    var initialPieces = [Piece]()
    for piece in compactPieceList {
      let newPieces = Array.init(repeating: piece.createPieceWithSameType(value: 1), count: piece.value())
      initialPieces.append(contentsOf: newPieces)
    }
    return initialPieces
  }
  
  static func shuffle(_ p: [Piece]) -> [Piece] {
    var pieces = p
    if pieces.count < 2 {
      return pieces
    }
    
    // Flip a coin to reserve or not if there are just two
    if pieces.count == 2 {
      return numericCast(arc4random_uniform(2)) == 1 ? pieces : pieces.reversed()
    }
    
    // For 3 or more we use https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    for i in 1...(pieces.count - 2) {
      let j = i + numericCast(arc4random_uniform(numericCast(pieces.count - i)))
      let swap = pieces[i]
      pieces[i] = pieces[j]
      pieces[j] = swap
    }
    return pieces
  }
}
