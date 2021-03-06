//
//  EditGameViewController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/28/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import UIKit

enum selectedButton {
  case piece(Piece)
  case increment(Int)
  case none
}

protocol EditGameViewControllerDelegate: NSObjectProtocol {
  func add(level: GameModel)
}

private let INITIAL_BOARD_SIZE = 5

final class EditGameViewController: UIViewController {
  var _gameModel = try! GameModel(name: "",
                                  collapsedPieces: [],
                                  initialBoard: Array.init(repeating:Array.init(repeating: Piece.empty,
                                                                                count: INITIAL_BOARD_SIZE),
                                                           count: INITIAL_BOARD_SIZE))
  var _view = EditGameView(frame:CGRect.zero)
  var _selectedPiece: Piece?
  
  weak var delegate: EditGameViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = _view
    self.setupNavigationBar()
    _view._sizeStepper.value = Double(_gameModel.boardSize())
    
    refreshViews()
    
    _view._sizeStepper.addTarget(self, action: #selector(sizeStepperTapped), for: UIControlEvents.valueChanged)

    _view.isUserInteractionEnabled = true
    _view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTap(gesture:))))
  }
  
  func setupNavigationBar() {
    self.navigationItem.title = "Create Level"
    self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Save",
                                                          style: UIBarButtonItemStyle.plain,
                                                          target: self,
                                                          action: #selector(didTapSave)), animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    _view._name.text = ""
  }
  
  func setModel(model: GameModel) {
    _gameModel = model.copy()
    _gameModel.collapsePieceList()
    _view._sizeStepper.value = Double(_gameModel.boardSize())
    refreshViews()
  }
  
  func refreshViews() {
    _view._board.updateModel(board: _gameModel._board._board)
    _view._remainingPieces.updatePiecesLeft(pieces: _gameModel._pieces)
  }
  
  @objc func sizeStepperTapped() {
    let size = Int(_view._sizeStepper.value)
    _gameModel = try! GameModel(name: "",
                                collapsedPieces: [],
                                initialBoard: Array.init(repeating:Array.init(repeating: Piece.empty,
                                                                              count: size),
                                                         count: size))
    refreshViews()
  }
  
  @objc func userDidTap(gesture: UITapGestureRecognizer) {
    if _view._name.isFirstResponder {
      _view._name.resignFirstResponder()
      return
    }
    
    let location = gesture.location(in: _view)
    let hitView = _view.hitTest(location, with: nil)
    if hitView is PieceView {
      let pieceView = hitView as! PieceView
      if (pieceView.superview is BoardView) {
        didTapBoard(at: location)
      } else if (pieceView.superview is RemainingPiecesView) {
        didTapRemainingPieces()
      } else {
        didTapPieceButton(pieceView: pieceView)
      }
    }
    
    if hitView is BoardView {
      didTapBoard(at: location)
    }
    
    if hitView is RemainingPiecesView {
      didTapRemainingPieces()
    }
  }
  
  func didTapPieceButton(pieceView: PieceView) {
    // If you select the same piece we swap between increment and decrement
    if _selectedPiece != nil && pieceView._model.sameType(otherPiece: _selectedPiece!) {
      _selectedPiece = _selectedPiece?.increment(-2 * (_selectedPiece?.value())!)
      pieceView.setPiece(model: _selectedPiece!)
      pieceView.setNeedsLayout()
    } else {
      _selectedPiece = pieceView._model
    }
    
    // Set background colors
    for otherPieceView in _view._pieceButtons {
      if otherPieceView == pieceView {
        pieceView.backgroundColor = UIColor.lightGray
      } else {
        otherPieceView.backgroundColor = UIColor.white
      }
    }
  }
  
  func didTapBoard(at: CGPoint) {
    if (_selectedPiece == nil) {
      return
    }
    
    let boardOrigin = _view._board.frame.origin
    let column = Int(floor((at.x - boardOrigin.x) / _view._board.singleSquareSize()))
    let row = _gameModel._board.rowCount() - 1 - Int(floor((at.y - boardOrigin.y) / _view._board.singleSquareSize()))
    
    let existingPiece = _gameModel._board._board[column][row]
    var pieceToAdd = _selectedPiece!
    if (_selectedPiece != nil && existingPiece.sameType(otherPiece: _selectedPiece!)) {
      pieceToAdd = existingPiece.increment(_selectedPiece!.value())
    }
    if pieceToAdd.value() < 1 {
      pieceToAdd = Piece.empty
    }
    _gameModel._board.addPiece(piece: pieceToAdd, row: row, column: column)
    
    _view._board.updateModel(board: _gameModel._board._board)
  }
  
  func didTapRemainingPieces() {
    if (_selectedPiece == nil || !_selectedPiece!.moves()) {
      return
    }
    
    _gameModel._pieces = _gameModel._pieces.map { (piece) -> Piece in
      if _selectedPiece!.sameType(otherPiece: piece) && (piece.value() + _selectedPiece!.value() >= 0) {
        return piece.increment(_selectedPiece!.value())
      } else {
        return piece
      }
    }
    
    if !_gameModel._pieces.contains(where: {_selectedPiece!.sameType(otherPiece: $0)}) && _selectedPiece!.value() > 0 {
      _gameModel._pieces.append(_selectedPiece!)
    }
    
    _view._remainingPieces.updatePiecesLeft(pieces: _gameModel._pieces)
  }
  
  func didTapBack() {
    let _ = self.navigationController?.popViewController(animated: true)
  }
  
  @objc func didTapSave() {
    if _view._name.text == "" {
      let alert = UIAlertController(title: nil,
                                    message: "You must add a name",
                                    preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
      
      return
    }
    
    _gameModel._levelName = _view._name.text!

    do {
      try LevelController.saveLocally(level: _gameModel)
      try LevelController.recordUserCreatedLevelOnServer(level: _gameModel)
      
      if let username = UserController.getUsername() {
        _gameModel._creatorName = username
      }
      _gameModel._levelType = LevelType.UserCreated
      delegate!.add(level: _gameModel)
    } catch {
      let alert = UIAlertController(title: nil,
                                    message: "Error while attempting to save level",
                                    preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
      
      return
    }
    
    let _ = self.navigationController?.popViewController(animated: true)
  }
}
