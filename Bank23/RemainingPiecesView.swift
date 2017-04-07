//
//  RemainingPiecesView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 1/3/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import UIKit

class RemainingPiecesView: UIView {
  var _piecesLeft = [PieceView]()
  let _label = UILabel()
  
  let squareSize = CGFloat(60.0)
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    _label.text = "Remaining"
    _label.font = UIFont.boldSystemFont(ofSize: 16.0)
    _label.textColor = PieceView.labelColor()
    self.addSubview(_label)
    
    self.backgroundColor = BoardView.backgroundColor()
    self.layer.cornerRadius = 4
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    _label.sizeToFit()
    _label.frame = CGRect(x: 4, y: 4, width:_label.frame.width, height: _label.frame.height)
    for (index, pieceView) in _piecesLeft.enumerated() {
      pieceView.frame = CGRect(x: 4 + CGFloat(index) * (squareSize + 5),
                               y: _label.frame.maxY + 9,
                               width: squareSize,
                               height: squareSize)
    }
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: squareSize * CGFloat(_piecesLeft.count) + 2 * 4 + 10,
                  height: _label.frame.height + squareSize + 3 * 4 + 5)
  }
  
  func updatePiecesLeft(pieces: [Piece]) {
    for subview in _piecesLeft {
      subview.removeFromSuperview()
    }
    _piecesLeft = [PieceView]()
    
    var coinsPiece = Piece.coins(0)
    var sandPiece = Piece.sand(0)
    for piece in pieces {
      switch piece {
      case .coins(_):
        coinsPiece = coinsPiece + piece
        break
      case .sand(_):
        sandPiece = sandPiece + piece
        break
      default:
        // Throw error
        break
      }
    }
    
    let coinPieceView = PieceView(frame: CGRect.zero, model: coinsPiece, row: -1, column: -1)
    let sandPieceView = PieceView(frame: CGRect.zero, model: sandPiece, row: -1, column: -1)
    coinPieceView.countLabelXPadding = CGFloat(-5.0)
    coinPieceView.countLabelYPadding = CGFloat(-5.0)
    sandPieceView.countLabelXPadding = CGFloat(-5.0)
    sandPieceView.countLabelYPadding = CGFloat(-5.0)
    self.addSubview(coinPieceView)
    self.addSubview(sandPieceView)
    _piecesLeft.append(coinPieceView)
    _piecesLeft.append(sandPieceView)
    self.setNeedsLayout()
  }
}
