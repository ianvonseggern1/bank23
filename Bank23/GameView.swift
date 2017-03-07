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
  let _refreshButton: UIButton
  let _menuIcon: UIButton
  let _victoryLabel: UILabel
  let _levelMenu: UITableView
  let _editButton: UIButton
  let _remainingPiecesView: RemainingPiecesView
  let _nextPieceView: NextPieceView
  
  init(frame: CGRect, rowCount: Int, columnCount: Int) {
    _board = BoardView(frame: CGRect.zero, rowCount: rowCount, columnCount: columnCount)
    _refreshButton = UIButton()
    _editButton = UIButton()
    _menuIcon = UIButton()
    _victoryLabel = UILabel()
    _remainingPiecesView = RemainingPiecesView(frame: CGRect.zero)
    _nextPieceView = NextPieceView(frame: CGRect.zero)
    _levelMenu = UITableView()
    
    super.init(frame:frame)
    
    self.backgroundColor = UIColor.white

    self.addSubview(_board)
    
    self.addSubview(_remainingPiecesView)
    self.addSubview(_nextPieceView)

    _refreshButton.setImage(UIImage(named: "refresh.png"), for: UIControlState.normal)
    _refreshButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    self.addSubview(_refreshButton)
    
    _editButton.setImage(UIImage(named:"edit-icon.png"), for: UIControlState.normal)
    _editButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    self.addSubview(_editButton)
    
    _menuIcon.setImage(UIImage(named: "menu-icon.png"), for: UIControlState.normal)
    _menuIcon.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    self.addSubview(_menuIcon)
    
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
    
    _refreshButton.frame = CGRect(x: bounds.width - 50, y: 25, width: 45, height: 45)
    _editButton.frame = CGRect(x: _refreshButton.frame.minX - 45, y: 25, width: 45, height: 45)
    _menuIcon.frame = CGRect(x: 5, y: 25, width: 45, height: 45)
    
    _levelMenu.frame = CGRect(x: 0,
                              y: _menuIcon.frame.maxY,
                              width: bounds.width * 3 / 4,
                              height: bounds.height - _menuIcon.frame.maxY)
    
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
  
  func update(board: [[Piece]], pieces: [Piece]) {
    self._nextPieceView.setPieceModel(piece: pieces.last)
    _remainingPiecesView.updatePiecesLeft(pieces: pieces)
    _board.updateModel(board: board)
    self.setNeedsLayout()
  }

}
