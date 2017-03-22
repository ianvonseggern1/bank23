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

final class EditGameViewController: UIViewController {
  var _board = Board()
  var _pieces = [Piece]()
  var _view: EditGameView
  var _selectedPiece: Piece?
  
  var levelMenuController: LevelMenuController?

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    _view = EditGameView(frame:CGRect.zero)

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    _view = EditGameView(frame:CGRect.zero)

    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view = _view
    self.setupNavigationBar()

    let initialBoardSize = 5
    _view._sizeStepper.value = Double(initialBoardSize)
    self.setEmptyBoardModel(size: initialBoardSize)
    
    _view._sizeStepper.addTarget(self, action: #selector(sizeStepperTapped), for: UIControlEvents.valueChanged)

    _view.isUserInteractionEnabled = true
    _view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTap(gesture:))))
    
    _pieces.append(Piece.coins(0))
    _pieces.append(Piece.sand(0))
    _view._remainingPieces.updatePiecesLeft(pieces: _pieces)
  }
  
  func setupNavigationBar() {
    self.navigationItem.title = "Create Level"
    self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Save",
                                                          style: UIBarButtonItemStyle.plain,
                                                          target: self,
                                                          action: #selector(didTapSave)), animated: true)
  }
  
  func setEmptyBoardModel(size: Int) {
    _board = try! Board(initialBoard: Array(repeating:Array(repeating:Piece.empty, count:size), count:size))
    _view._board.updateModel(board: _board._board)
  }
  
  func sizeStepperTapped() {
    self.setEmptyBoardModel(size: Int(_view._sizeStepper.value))
  }
  
  func userDidTap(gesture: UITapGestureRecognizer) {
    _view._name.resignFirstResponder()
    
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
    let row = _board.rowCount() - 1 - Int(floor((at.y - boardOrigin.y) / _view._board.singleSquareSize()))
    
    let existingPiece = _board._board[column][row]
    var pieceToAdd = _selectedPiece!
    if (_selectedPiece != nil && existingPiece.sameType(otherPiece: _selectedPiece!)) {
      pieceToAdd = existingPiece.increment(_selectedPiece!.value())
    }
    if pieceToAdd.value() < 1 {
      pieceToAdd = Piece.empty
    }
    _board.addPiece(piece: pieceToAdd, row: row, column: column)
    
    _view._board.updateModel(board: _board._board)
  }
  
  func didTapRemainingPieces() {
    if (_selectedPiece == nil || !_selectedPiece!.moves()) {
      return
    }
    
    var newPieces = [Piece]()
    for piece in _pieces {
      if _selectedPiece!.sameType(otherPiece: piece) && (piece.value() + _selectedPiece!.value() >= 0) {
        newPieces.append(piece.increment(_selectedPiece!.value()))
      } else {
        newPieces.append(piece)
      }
    }
    _pieces = newPieces
    _view._remainingPieces.updatePiecesLeft(pieces: _pieces)
  }
  
  func didTapBack() {
    let _ = self.navigationController?.popViewController(animated: true)
  }
  
  func didTapSave() {
    if _view._name.text == "" {
      let alert = UIAlertController(title: nil,
                                    message: "You must add a name",
                                    preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
      
      return
    }

    do {
      let gameModel = try GameModel(name: _view._name.text!,
                                    initialPieces: _pieces,
                                    initialBoard: _board._board)
      try LevelNetworker.writeLevelToDatabase(level: gameModel)
      
      // For now we write it locally to the level menu controller and to the DB
      levelMenuController!.add(level: gameModel)
    } catch {
      let alert = UIAlertController(title: nil,
                                    message: "Error while attampting to save level",
                                    preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
      
      return
    }
    
    let _ = self.navigationController?.popViewController(animated: true)
  }
}
