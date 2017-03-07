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
}

public class Board {
  var _board = [[Piece]]() // Board is an array of columns, so index with [column][row]. 0, 0 is bottom left
  var _rows = 0
  var _columns = 0
  
  public init() {
  }
  
  public init(initialBoard: [[Piece]]) throws {
    (_rows, _columns) = try getRowAndColumnCount(board: initialBoard)
    _board = initialBoard
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
    var nextBoard = Array(repeating:Array(repeating:Piece.empty, count:_rows), count:_columns)
    
    // Collapse all existing
    switch from {
    case .top:
      for (index, column) in _board.enumerated() {
        nextBoard[index] = collapseColumn(column: column)
      }
      break
    case .bottom:
      for (index, column) in _board.enumerated() {
        nextBoard[index] = collapseColumn(column: column.reversed()).reversed()
      }
      break
    case .left:
      for rowIndex in 0...(_rows - 1) {
        let row = _board.map({ (column: [Piece]) -> Piece in
          return column[rowIndex]
        })
        let newRow:[Piece] = collapseColumn(column: row.reversed()).reversed()
        for (columnIndex, _) in nextBoard.enumerated() {
          nextBoard[columnIndex][rowIndex] = newRow[columnIndex]
        }
      }
      break
    case .right:
      for rowIndex in 0...(_rows - 1) {
        let row = _board.map({ (column: [Piece]) -> Piece in
          return column[rowIndex]
        })
        let newRow:[Piece] = collapseColumn(column: row)
        for (columnIndex, _) in nextBoard.enumerated() {
          nextBoard[columnIndex][rowIndex] = newRow[columnIndex]
        }
      }
      break
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
  
  // Win iff there are no banks left
  func isWon() -> Bool {
    for column in _board {
      for piece in column {
        if piece.sameType(otherPiece: Piece.bank(1)) && piece.value() > 0 {
          return false
        }
      }
    }
    return true
  }
  
  // Returns true if there is no possible way to win
  func isLost(remainingCoins: Int) -> Bool {
    var coinsOnBoard = 0
    var banksOnBoard = 0
    for column in _board {
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
  
  func collapseColumn(column: [Piece]) -> [Piece] {
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
  
  // Used to animate partial user swipe
  func findMovablePieces(swipeDirection: Direction) -> [[Bool]] {
    var canMove = Array(repeating:Array(repeating:false, count:_rows), count:_columns)
    
    // Collapse all existing
    switch swipeDirection {
    case .top:
      for (index, column) in _board.enumerated() {
        canMove[index] = findMovablePiecesInColumn(column: column)
      }
      break
    case .bottom:
      for (index, column) in _board.enumerated() {
        canMove[index] = findMovablePiecesInColumn(column: column.reversed()).reversed()
      }
      break
    case .left:
      for rowIndex in 0...(_rows - 1) {
        let row = _board.map({ (column: [Piece]) -> Piece in
          return column[rowIndex]
        })
        let canMoveRow:[Bool] = findMovablePiecesInColumn(column: row.reversed()).reversed()
        for (columnIndex, _) in canMove.enumerated() {
          canMove[columnIndex][rowIndex] = canMoveRow[columnIndex]
        }
      }
      break
    case .right:
      for rowIndex in 0...(_rows - 1) {
        let row = _board.map({ (column: [Piece]) -> Piece in
          return column[rowIndex]
        })
        let canMoveRow:[Bool] = findMovablePiecesInColumn(column: row)
        for (columnIndex, _) in canMove.enumerated() {
          canMove[columnIndex][rowIndex] = canMoveRow[columnIndex]
        }
      }
      break
    }
    
    return canMove
  }
  
  func findMovablePiecesInColumn(column: [Piece]) -> [Bool] {
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
