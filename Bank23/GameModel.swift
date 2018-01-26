//
//  GameModel.swift
//  Bank23
//
//  Created by Ian Vonseggern on 3/22/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

enum LevelType {
  case Undefined
  case BuiltIn // TODO, decide if I'm keeping any of these
  case Server
  case UserCreated // Local
}

private let PIECE_LIST_STRING_PIECE_SEPERATOR = "."
private let MODEL_STRING_SEPERATOR = ","

public final class GameModel {
  var _board = Board()
  var _pieces = [Piece]()
  var _levelName = ""
  var _creatorName: String?
  var _explanationLabel: String? // Used for tutorials
  var _sortKey = "zzzzz" // Default to a high value to put things lacking a sort key in back. Like user created levels
  var _levelType: LevelType = LevelType.Undefined
  
  public init() {
  }

  public init(name: String, collapsedPieces: [Piece], initialBoard: [[Piece]]) throws {
    _levelName = name
    _board = try Board(initialBoard: initialBoard)
    _pieces = GameModel.shuffle(GameModel.expandPieces(collapsedPieces))
  }
  
  public init(name: String, initialPiecesString: String, initialBoardString: String) throws {
    _levelName = name
    let compactPieces = try GameModel.pieceListFromString(initialPiecesString)
    _pieces = GameModel.shuffle(GameModel.expandPieces(compactPieces))
    _board = try Board(fromString: initialBoardString)
  }
  
  // We concatonate board, pieces, name in that order
  public func toString() -> String {
    var modelParts: [String] = [];
    modelParts.append(_board.toString())
    modelParts.append(self.collapsedPieceListToString())
    modelParts.append(_levelName)
    modelParts.append(_sortKey)
    modelParts.append(_explanationLabel ?? "")
    return modelParts.joined(separator: MODEL_STRING_SEPERATOR)
  }
  
  public static func fromString(_ modelString: String) throws -> GameModel {
    let modelParts = modelString.components(separatedBy: MODEL_STRING_SEPERATOR)
    let model = try GameModel(name: modelParts[2],
                              initialPiecesString: modelParts[1],
                              initialBoardString: modelParts[0])
    if modelParts.count > 3 {
      model._sortKey = modelParts[3]
    }
    if modelParts.count > 4 && modelParts[4].count > 0 {
      model._explanationLabel = modelParts[4]
    }
    return model
  }
  
  // Note this function reshuffles the pieces
  public func copy() -> GameModel {
    // Arrays use copy symantics so we can just create a new model
    let copy = try! GameModel(name:self._levelName,
                              collapsedPieces:self._pieces,
                              initialBoard:self._board._board)
    copy._creatorName = self._creatorName
    copy._explanationLabel = self._explanationLabel
    copy._sortKey = self._sortKey
    copy._levelType = self._levelType
    
    return copy
  }
  
  func hash() -> UInt64 {
    let gameString = _board.toString().appending(self.collapsedPieceListToString())
    return strHash(gameString)
  }
  
  func strHash(_ str: String) -> UInt64 {
    var result = UInt64 (5381)
    let buf = [UInt8](str.utf8)
    for b in buf {
      result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
  }
  
  func boardSize() -> Int {
    if _board._rows != _board._columns {
      print("Error: while board model supports rows != columns, consumers of API assume these are equal")
    }
    return _board._rows
  }
  
  // Win iff there are no banks left
  func isWon() -> Bool {
    return self.bankCount() == 0
  }
  
  // Returns true if there are not enough coins left to fill the banks
  func isLost() -> Bool {
    return self.coinCount() < self.bankCount()
  }
  
  // This calculates the number of pieces dropped in the water between an old
  // model and new model. It relies on the assumption that the only way to lose
  // coins without decrementing banks is by dropping them in water.
  public func coinsLostToWaterCount(oldModel: GameModel) -> Int {
    let banksFilled = oldModel.bankCount() - self.bankCount()
    let coinsLost = oldModel.coinCount() - self.coinCount()
    return coinsLost - banksFilled
  }
  
  // This calculates the number of coins placed into banks by counting the total
  // bank count in each model and subtracting
  public func coinsUsedInBanksCount(oldModel: GameModel) -> Int {
    return oldModel.bankCount() - self.bankCount()
  }
  
  public func bankCount() -> Int {
    return countPiecesOnBoard(ofType: Piece.bank(1))
  }
  
  public func coinCount() -> Int {
    return countPiecesOnBoard(ofType: Piece.coins(1)) + countPiecesRemaining(ofType: Piece.coins(1))
  }
  
  private func countPiecesOnBoard(ofType: Piece) -> Int {
    var count = 0
    for column in _board._board {
      for piece in column {
        if piece.sameType(otherPiece: ofType) {
          count += piece.value()
        }
      }
    }
    return count
  }
  
  private func countPiecesRemaining(ofType: Piece) -> Int {
    var count = 0
    for piece in _pieces {
      if piece.sameType(otherPiece: ofType) {
        count += piece.value()
      }
    }
    return count
  }
  
  public func collapsePieceList() {
    _pieces = GameModel.collapsePieces(_pieces)
  }
  
  public func collapsedPieceListToString() -> String {
    return GameModel.pieceListToString(pieces: GameModel.collapsePieces(_pieces))
  }
  
  public static func pieceListToString(pieces: [Piece]) -> String {
    return pieces.map({ (piece: Piece) -> String in
      return piece.shortName()
    }).joined(separator: PIECE_LIST_STRING_PIECE_SEPERATOR)
  }
  
  public static func pieceListFromString(_ pieceListString: String) throws -> [Piece] {
    if pieceListString.count == 0 {
      return []
    }
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
  
  static func collapsePieces(_ expandedPieceList: [Piece]) -> [Piece] {
    var collapsedPieces = [String: Piece]()
    for piece in expandedPieceList {
      if let currentPiece = collapsedPieces[piece.typeName()] {
        // NOTE this used to be currentPiece.increment(currentPiece) which was wrong
        // but I don't know what bugs will ensue from fixing it
        collapsedPieces[piece.typeName()] = try! currentPiece.increment(piece)
      } else {
        collapsedPieces[piece.typeName()] = piece
      }
    }
    return collapsedPieces.values.sorted(by: { $0.typeName() > $1.typeName() })
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
