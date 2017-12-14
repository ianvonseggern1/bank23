//
//  Board.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/16/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation

enum BoardModelError: Error {
  case initialBoardNotRectangle
}

public enum Direction {
  case left
  case right
  case top
  case bottom
  
  static func toString(_ direction: Direction) -> String {
    switch direction {
    case left:
      return "l"
    case right:
      return "r"
    case top:
      return "t"
    case bottom:
      return "b"
    }
  }
}



public final class Board : NSCoding {
  var _board = [[Piece]]() // Board is an array of columns, so index with [column][row]. 0, 0 is bottom left
  var _rows = 0
  var _columns = 0
  
  private let BOARD_STRING_COLUMN_SEPERATOR = "_"
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(_board, forKey: "boardArray")
  }
  
  public init?(coder aDecoder: NSCoder) {
    _board = aDecoder.decodeObject(forKey: "boardArray") as! [[Piece]]
    (_rows, _columns) = try! getRowAndColumnCount(board: _board)
  }
  
  public init(initialBoard: [[Piece]]) throws {
    (_rows, _columns) = try getRowAndColumnCount(board: initialBoard)
    _board = initialBoard
  }
  
  public init(fromString boardString: String) throws {
    _board = try boardString.components(separatedBy: BOARD_STRING_COLUMN_SEPERATOR).map({ (columnString) -> [Piece] in
      return try GameModel.pieceListFromString(columnString)
    })
    (_rows, _columns) = try getRowAndColumnCount(board: _board)
  }
  
  public init() {
  }
  
  public func toString() -> String {
    return _board.reduce("", { (oldColumnString, column) -> String in
      var newColumnString: String
      if oldColumnString.count > 0 {
        newColumnString = oldColumnString.appending(BOARD_STRING_COLUMN_SEPERATOR)
      } else {
        newColumnString = oldColumnString
      }
      return newColumnString.appending(GameModel.pieceListToString(pieces: column))
    })
  }
  
  public static func == (x: Board, y: Board) -> Bool {
    if x._board.count != y._board.count {
      return false
    }
    for i in 0..<x._board.count {
      if x._board[i].count != y._board[i].count {
        return false
      }
      for j in 0..<x._board[i].count {
        if x._board[i][j] != y._board[i][j] {
          return false
        }
      }
    }
    return true
  }
  
  func getRowAndColumnCount(board: [[Piece]]) throws -> (Int, Int) {
    let columnCount = board.count
    let rowCount = board[0].count
    for column in board {
      if column.count != rowCount {
        throw BoardModelError.initialBoardNotRectangle
      }
    }
    return (rowCount, columnCount)
  }
  
  func rowCount() -> Int {
    return _rows
  }
  
  func columnCount() -> Int {
    return _columns
  }
  
  // To setup board
  func clear() {
    _board = Array(repeating:Array(repeating:Piece.empty, count:_rows), count:_columns)
  }

  func addPiece(piece: Piece, row: Int, column: Int) {
    if (row < 0 || column < 0 || row >= _rows || column >= _columns) {
      // THROW ERROR
      return
    }
    _board[column][row] = piece
  }
  
  // Main action taken by user - returns location of new piece, nil if it can't be swipped on
  // doesn't actually place new piece on board yet, you have to manually call mergePiece for that
  func swipePieceOn(newPiece: Piece, from: Direction) -> (Int, Int)? {
    var nextBoard = applyColumnFunction(swipeDirection: from,
                                        function: {collapseColumn(column: $0)},
                                        defaultValue: Piece.empty)
    
    // We don't need to look for places to put the next piece if we are out of
    // remaining pieces
    if newPiece == Piece.empty {
      _board = nextBoard
      return nil
    }
    
    // Find eligable spots for new piece
    var eligibleSpots = [(Int, Int)]()
    switch from {
    case .top:
      for (columnIndex, column) in nextBoard.enumerated() {
        if (newPiece.joinInto(existing: column[column.count - 1]) != nil) {
          eligibleSpots.append((columnIndex, column.count - 1))
        }
      }
    case .bottom:
      for (columnIndex, column) in nextBoard.enumerated() {
        if (newPiece.joinInto(existing: column[0]) != nil) {
          eligibleSpots.append((columnIndex, 0))
        }
      }
    case .left:
      for (rowIndex, piece) in nextBoard[0].enumerated() {
        if (newPiece.joinInto(existing: piece) != nil) {
          eligibleSpots.append((0, rowIndex))
        }
      }
    case .right:
      for (rowIndex, piece) in nextBoard[_board.count - 1].enumerated() {
        if (newPiece.joinInto(existing: piece) != nil) {
          eligibleSpots.append((_board.count - 1, rowIndex))
        }
      }
    }
    
    if (eligibleSpots.count == 0) {
      return nil
    }
    let (column, row) = eligibleSpots[Int(arc4random_uniform(UInt32(eligibleSpots.count)))]
    _board = nextBoard
    return (column, row)
  }
  
  func mergePiece(piece: Piece, row: Int, column: Int) {
    _board[column][row] = piece.joinInto(existing: _board[column][row])!
  }
  
  private func collapseColumn(column: [Piece]) -> [Piece] {
    var column = column
    var newColumn = Array(repeating: Piece.empty, count: column.count)
    for index in 0...(column.count - 2) {
      let currentPiece = column[index]
      let nextPiece = column[index + 1]
      let newPiece = nextPiece.joinInto(existing: currentPiece)
      if newPiece != nil {
        newColumn[index] = newPiece!
        column[index + 1] = Piece.empty
      } else {
        newColumn[index] = currentPiece
      }
    }
    newColumn[column.count - 1] = column[column.count - 1]
    return newColumn
  }
  
  // Allows you to define func's that apply to a single column regardless of swipe direction
  // it handles applying that func properly in the appropriate direction
  //
  // Convention here is for the function to assume swipes happen from higher indicies toward
  // lower ones
  private func applyColumnFunction<T>(swipeDirection: Direction,
                                   function: ([Piece]) -> [T],
                                   defaultValue: T) -> [[T]] {
    var rtn = Array(repeating:Array(repeating:defaultValue, count:_rows), count:_columns)
    
    switch swipeDirection {
    case .top:
      for (index, column) in _board.enumerated() {
        rtn[index] = function(column)
      }
      break
    case .bottom:
      for (index, column) in _board.enumerated() {
        rtn[index] = function(column.reversed()).reversed()
      }
      break
    case .left:
      for rowIndex in 0...(_rows - 1) {
        let row = _board.map({ (column: [Piece]) -> Piece in
          return column[rowIndex]
        })
        let rtnRow:[T] = function(row.reversed()).reversed()
        for (columnIndex, _) in rtn.enumerated() {
          rtn[columnIndex][rowIndex] = rtnRow[columnIndex]
        }
      }
      break
    case .right:
      for rowIndex in 0...(_rows - 1) {
        let row = _board.map({ (column: [Piece]) -> Piece in
          return column[rowIndex]
        })
        let rtnRow:[T] = function(row)
        for (columnIndex, _) in rtn.enumerated() {
          rtn[columnIndex][rowIndex] = rtnRow[columnIndex]
        }
      }
      break
    }
    
    return rtn
  }
  
  // Used to animate partial user swipe
  func findMovablePieces(swipeDirection: Direction) -> [[Bool]] {
    return applyColumnFunction(swipeDirection: swipeDirection,
                               function: { findMovablePiecesInColumn(column: $0) },
                               defaultValue: false)
  }
  
  // Used to animate coins or sand joining with themselves after a swipe
  //
  // Sets only the index of the new pieces location to true, because the mask is used
  // after the model is updated after the swipe
  func findIncrementedPieces(swipeDirection: Direction) -> [[Bool]] {
    return applyColumnFunction(swipeDirection: swipeDirection,
                               function: { findIncrementedPiecesInColumn(column: $0) },
                               defaultValue: false)
  }
  
  private func findIncrementedPiecesInColumn(column: [Piece]) -> [Bool] {
    var tempColumn = column
    var willBeIncremented = Array(repeating: false, count: column.count)
    for index in 0...(column.count - 2) {
      let priorPiece = tempColumn[index]
      let currentPiece = tempColumn[index + 1]
      if currentPiece != Piece.empty {
        if currentPiece.joinInto(existing: priorPiece) != nil {
          if currentPiece.sameType(otherPiece: priorPiece) {
            willBeIncremented[index] = true
          }
          tempColumn[index + 1] = Piece.empty
        }
      }
    }
    return willBeIncremented
  }
  
  private func findMovablePiecesInColumn(column: [Piece]) -> [Bool] {
    var tempColumn = column
    var canMove = Array(repeating: false, count: column.count)
    for index in 0...(column.count - 2) {
      let priorPiece = tempColumn[index]
      let currentPiece = tempColumn[index + 1]
      if currentPiece != Piece.empty {
        if currentPiece.joinInto(existing: priorPiece) != nil {
          canMove[index + 1] = true
          tempColumn[index + 1] = Piece.empty
        }
      }
    }
    return canMove
  }
}
