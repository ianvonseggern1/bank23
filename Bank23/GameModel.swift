//
//  GameModel.swift
//  Bank23
//
//  Created by Ian Vonseggern on 3/22/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

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
    let compactPieces = try Piece.pieceListFromString(initialPiecesString)
    _pieces = GameModel.shuffle(GameModel.expandPieces(compactPieces))
    _board = try Board(fromString: initialBoardString)
  }
  
  public func copy() -> GameModel {
    return try! GameModel(name:self._levelName,
                          initialPieces:self._pieces,
                          initialBoard:self._board._board)
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
