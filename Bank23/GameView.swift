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
  let _board: BoardView
  let _victoryLabel: UILabel
  let _levelMenu: UITableView
  let _remainingPiecesView: RemainingPiecesView
  let _nextPieceView: NextPieceView
  
  override init(frame: CGRect) {
    _board = BoardView(frame: CGRect.zero)
    _victoryLabel = UILabel()
    _remainingPiecesView = RemainingPiecesView(frame: CGRect.zero)
    _nextPieceView = NextPieceView(frame: CGRect.zero)
    _levelMenu = UITableView()
    
    super.init(frame:frame)
    
    self.backgroundColor = UIColor.white

    self.addSubview(_board)
    
    self.addSubview(_remainingPiecesView)
    self.addSubview(_nextPieceView)
    
    _levelMenu.isHidden = true
    self.addSubview(_levelMenu)
    
    _victoryLabel.text = "YOU WON!"
    _victoryLabel.font = UIFont.systemFont(ofSize: 48, weight: 1.0)
    _victoryLabel.isHidden = true
    self.addSubview(_victoryLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    let bounds = self.frame
    
    // todo replace 60 with actual height of navigation bar
    _levelMenu.frame = CGRect(x: 0,
                              y: 60,
                              width: bounds.width * 3 / 4,
                              height: bounds.height - 60)
    
    _victoryLabel.sizeToFit()
    _victoryLabel.frame = CGRect(x: (bounds.width - _victoryLabel.frame.width) / 2.0,
                                 y: (bounds.height - _victoryLabel.frame.height) / 2.0,
                                 width: _victoryLabel.frame.width,
                                 height: _victoryLabel.frame.height)

    let boardSize = _board.sizeThatFits(CGSize(width: bounds.width - 2 * BOARD_PADDING,
                                               height: bounds.height - 2 * BOARD_PADDING))
    _board.frame = CGRect(x: (bounds.width - boardSize.width) / 2,
                          y: (bounds.height - boardSize.height) / 2 + 50,
                          width: boardSize.width,
                          height: boardSize.height)
    
    _remainingPiecesView.sizeToFit()
    _remainingPiecesView.frame = CGRect(x: _board.frame.minX,
                                        y: _board.frame.minY - 15 - _remainingPiecesView.frame.height,
                                        width: _remainingPiecesView.frame.width,
                                        height: _remainingPiecesView.frame.height)
    
    _nextPieceView.sizeToFit()
    _nextPieceView.frame = CGRect(x: _board.frame.maxX - _nextPieceView.frame.width,
                                  y: _board.frame.minY - _nextPieceView.frame.height - 15,
                                  width: _nextPieceView.frame.width,
                                  height: _nextPieceView.frame.height)
  }
  
  func updateModel(_ game: GameModel) {
    self._nextPieceView.setPieceModel(piece: game._pieces.last)
    _remainingPiecesView.updatePiecesLeft(pieces: game._pieces)
    _board.updateModel(board: game._board._board)
    self.setNeedsLayout()
  }
}
