//
//  GameView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/23/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

let SINGLE_SQUARE_SIZE:CGFloat = 60.0
let BOARD_PADDING: CGFloat = 20.0

class GameView: UIView {
  let _board = BoardView(frame: CGRect.zero)
  let _victoryView = VictoryView(frame: CGRect.zero)
  let _remainingPiecesView = RemainingPiecesView(frame: CGRect.zero)
  let _nextPieceView = NextPieceView(frame: CGRect.zero)
  let _timerView = TimerView(frame: CGRect.zero)
  
  // Used to place text under the board in tutorials
  let _explanationLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    self.backgroundColor = UIColor.white

    self.addSubview(_board)
    
    self.addSubview(_remainingPiecesView)
    self.addSubview(_nextPieceView)
    self.addSubview(_timerView)
    
    self.addSubview(_victoryView)

    _explanationLabel.font = UIFont.systemFont(ofSize: 16.0)
    _explanationLabel.numberOfLines = 0
    _explanationLabel.textAlignment = NSTextAlignment.center
    self.addSubview(_explanationLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    let bounds = self.frame
    
    _victoryView.sizeToFit()
    _victoryView.frame = CGRect(x: (bounds.width - _victoryView.frame.width) / 2.0,
                                 y: (bounds.height - _victoryView.frame.height) / 2.0,
                                 width: _victoryView.frame.width,
                                 height: _victoryView.frame.height)
    
    _remainingPiecesView.sizeToFit()
    _nextPieceView.sizeToFit()
    _timerView.sizeToFit()
    let boardSize = _board.sizeThatFits(CGSize(width: bounds.width - 2 * BOARD_PADDING,
                                               height: bounds.height - 2 * BOARD_PADDING))
    
    _board.frame = CGRect(x: (bounds.width - boardSize.width) / 2,
                          y: 90 + _nextPieceView.frame.height + 15,
                          width: boardSize.width,
                          height: boardSize.height)
    
    _remainingPiecesView.frame = CGRect(x: _board.frame.minX,
                                        y: 90,
                                        width: _remainingPiecesView.frame.width,
                                        height: _remainingPiecesView.frame.height)

    _nextPieceView.frame = CGRect(x: _board.frame.maxX - _nextPieceView.frame.width,
                                  y: 90,
                                  width: _nextPieceView.frame.width,
                                  height: _nextPieceView.frame.height)
    
    // RemainingPieces, TimerView, and NextPiece are all adjacent and we want to center
    // the timer in the gap, so we calculate the total space and split it
    let extraHoziontalSpace = _board.frame.width - (_remainingPiecesView.frame.width +
                                                    _timerView.frame.width +
                                                    _nextPieceView.frame.width)
    _timerView.frame = CGRect(x: _remainingPiecesView.frame.maxX + extraHoziontalSpace / 2,
                              y: 90,
                              width: _timerView.frame.width,
                              height: _timerView.frame.height)
  
    let explanationSize = _explanationLabel.sizeThatFits(CGSize(width: bounds.width - 2 * BOARD_PADDING,
                                                                height: bounds.height - 30 - _board.frame.maxY))
    _explanationLabel.frame = CGRect(x: (bounds.width - explanationSize.width) / 2,
                                     y: _board.frame.maxY + (bounds.height - _board.frame.maxY - explanationSize.height) / 2,
                                     width: explanationSize.width,
                                     height: explanationSize.height)
  }
  
  func updateModel(_ game: GameModel) {
    self._nextPieceView.setPieceModel(piece: game._pieces.last)
    _remainingPiecesView.updatePiecesLeft(pieces: game._pieces)
    _board.updateModel(board: game._board._board)
    _explanationLabel.text = game._explanationLabel
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
}
