//
//  EditGameView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/27/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

class EditGameView: UIView, UITextFieldDelegate {
  let _board: BoardView
  var _pieceButtons = [PieceView]()
  let _backButton = UIButton()
  let _saveButton = UIButton()
  let _name = UITextField()
  let _remainingPieces = RemainingPiecesView(frame: CGRect.zero)

  init(frame: CGRect, rowCount: Int, columnCount: Int) {
    _board = BoardView(frame: CGRect.zero, rowCount: rowCount, columnCount: columnCount)
    
    super.init(frame:frame)
    
    self.backgroundColor = UIColor.white
    
    _backButton.setTitle("Back", for: UIControlState.normal)
    _backButton.setTitleColor(UIColor.black, for: UIControlState.normal)
    _backButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    self.addSubview(_backButton)
    
    _saveButton.setTitle("Save", for: UIControlState.normal)
    _saveButton.setTitleColor(UIColor.black, for: UIControlState.normal)
    _saveButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    self.addSubview(_saveButton)
    
    _name.placeholder = "Name"
    _name.textAlignment = NSTextAlignment.center
    _name.returnKeyType = UIReturnKeyType.done
    _name.delegate = self
    self.addSubview(_name)
    
    _pieceButtons = [Piece.bank(1), Piece.coins(1), Piece.water(1), Piece.sand(1)].map({ (piece: Piece) -> PieceView in
      let pieceView = PieceView(frame: CGRect.zero, model: piece, pieceColor: UIColor.white, row: -1, column: -1)
      self.addSubview(pieceView)
      return pieceView
    })
    
    self.addSubview(_remainingPieces)
    
    self.addSubview(_board)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    let bounds = self.bounds
    
    _backButton.sizeToFit()
    _backButton.frame = CGRect(x: 0, y: 25, width:_backButton.frame.width, height:_backButton.frame.height)
    
    _saveButton.sizeToFit()
    _saveButton.frame = CGRect(x: bounds.width - _saveButton.frame.width,
                               y: 25,
                               width: _saveButton.frame.width,
                               height: _saveButton.frame.height)
    
    _name.frame = CGRect(x: (bounds.width - 200) / 2,
                         y: 25,
                         width: 200,
                         height: 40)
    
    let pieceButtonsWidth = CGFloat(_pieceButtons.count) * SINGLE_SQUARE_SIZE
    for (index, piece) in _pieceButtons.enumerated() {
      piece.sizeToFit()
      piece.frame = CGRect(x: (bounds.width - pieceButtonsWidth) / 2 + CGFloat(index) * piece.frame.width,
                           y: _backButton.frame.maxY + 20,
                           width: piece.frame.width,
                           height: piece.frame.height)
    }

    _board.sizeToFit()
    _board.frame = CGRect(x: (bounds.width - _board.frame.width) / 2,
                          y: (bounds.height - _board.frame.height) / 2 + 100,
                          width: _board.frame.width,
                          height: _board.frame.height)
    
    _remainingPieces.sizeToFit()
    _remainingPieces.frame = CGRect(x: _board.frame.minX,
                                    y: _board.frame.minY - _remainingPieces.frame.height - 15,
                                    width: _remainingPieces.frame.width,
                                    height: _remainingPieces.frame.height)
  }
  
  // UITextFieldDelegate
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
