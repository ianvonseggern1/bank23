//
//  BoardView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/27/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

class BoardView: UIImageView {
  var _rowCount: Int
  var _columnCount: Int
  
  init(frame: CGRect, rowCount: Int, columnCount: Int) {
    _rowCount = rowCount
    _columnCount = columnCount
  
    super.init(frame:frame)
    
    self.backgroundColor = UIColor.lightGray
    self.isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    // draw lines
    UIGraphicsBeginImageContext(self.frame.size)
    let context = UIGraphicsGetCurrentContext()
    for i in 1...(_columnCount - 1) {
      let float_i = CGFloat(i)
      context?.move(to: CGPoint(x: self.singleSquareSize() * float_i, y: 0))
      context?.addLine(to: CGPoint(x: self.singleSquareSize() * float_i,
                                   y: self.singleSquareSize() * CGFloat(_rowCount)))
      context?.strokePath()
    }
    for i in 1...(_rowCount - 1) {
      let float_i = CGFloat(i)
      context?.move(to: CGPoint(x: 0, y: self.singleSquareSize() * float_i))
      context?.addLine(to: CGPoint(x: self.singleSquareSize() * CGFloat(_columnCount),
                                   y: self.singleSquareSize() * float_i))
      context?.strokePath()
    }
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  func singleSquareSize() -> CGFloat {
    return self.bounds.width / CGFloat(_columnCount)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var singleSquareSize = SINGLE_SQUARE_SIZE
    if singleSquareSize * CGFloat(_rowCount) > size.height {
      singleSquareSize = size.height / CGFloat(_rowCount)
      singleSquareSize.round(.down)
    }
    if singleSquareSize * CGFloat(_columnCount) > size.width {
      singleSquareSize = size.width / CGFloat(_columnCount)
      singleSquareSize.round(.down)
    }
    return CGSize(width: singleSquareSize * CGFloat(_columnCount),
                  height: singleSquareSize * CGFloat(_rowCount))
  }
  
  // Used to animate user pans, moves all the pieces that move that amount from their normal position in that direction
  // TODO make 'by' 0-1 as a ratio of a square size instead of an actual distance
  func adjust(movablePieceMask: [[Bool]], by: CGFloat, inDirection: Direction) {
    var xOffset: CGFloat
    var yOffset: CGFloat
    switch inDirection {
    case .bottom:
      xOffset = 0
      yOffset = -1 * by
      break
    case .top:
      xOffset = 0
      yOffset = by
    case .right:
      xOffset = -1 * by
      yOffset = 0
    case .left:
      xOffset = by
      yOffset = 0
    }
    
    for subview in self.subviews {
      let pieceview = subview as! PieceView
      if movablePieceMask[pieceview._column][pieceview._row] {
        pieceview.frame = CGRect(x: self.singleSquareSize() * CGFloat(pieceview._column) + xOffset,
                                 y:self.singleSquareSize() * CGFloat(_rowCount - 1 - pieceview._row) + yOffset,
                                 width:self.singleSquareSize(),
                                 height:self.singleSquareSize())
      }
    }
  }
  
  func updateModel(board: [[Piece]]) {
    _columnCount = board.count
    _rowCount = board[0].count

    for subview in self.subviews {
      subview.removeFromSuperview()
    }
    for (columnIndex, column) in board.enumerated() {
      for (rowIndex, piece) in column.enumerated() {
        if (piece != Piece.empty) {
          let _ = addPiece(piece: piece, row: rowIndex, col: columnIndex)
        }
      }
    }
    self.setNeedsLayout()
  }
  
  func addPiece(piece: Piece, row: Int, col: Int) -> PieceView {
    if (row < 0 || col < 0 || row >= _rowCount || col >= _columnCount) {
      assertionFailure("invalide row /(row) or col /(col) value passed to view")
    }
    let pieceView = PieceView(frame: CGRect(x: self.singleSquareSize() * CGFloat(col),
                                            y:self.singleSquareSize() * CGFloat(_rowCount - 1 - row),
                                            width:self.singleSquareSize(),
                                            height:self.singleSquareSize()),
                              model: piece,
                              pieceColor: UIColor.white,
                              row:row,
                              column:col)
    self.addSubview(pieceView)

    return pieceView
  }
}
