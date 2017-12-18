//
//  ViewController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/16/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, LevelMenuControllerDelegate {
  var  _view = GameView(frame:CGRect.zero)
  
  var _gameModel = GameModel()
  
  let _levelMenuController = LevelMenuController()

  var _currentSwipeDirection: Direction?
  var _showedIsLostAlert = false
  var _moves = [Direction]()
  var _initialShuffledPieces = [Piece]()

  // Unique to each 'round' reset when the board is reset. Allows us to
  // track moves and results in the database
  var _uniquePlayId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure level menu controller
    _levelMenuController.delegate = self
    _levelMenuController.fetchLevels()
    
    self.setupNavigationBarItems()
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(gesture:)))
    _view.addGestureRecognizer(panGesture)
    self.view = _view

    setupBoard()
    _view.updateModel(_gameModel)
    
    _view._victoryView.isHidden = true
    let nextLevelTap = UITapGestureRecognizer(target: self, action: #selector(didTapNextLevel))
    _view._victoryView._nextLevelLabel.isUserInteractionEnabled = true
    _view._victoryView._nextLevelLabel.addGestureRecognizer(nextLevelTap)
    
    self.navigationItem.title = _gameModel._levelName
  }
  
  func setupNavigationBarItems() {
    let menuIcon = UIButton()
    menuIcon.setImage(UIImage(named: "menu-icon25.png"), for: UIControlState.normal)
    menuIcon.bounds = CGRect(x: 0, y: 0, width: 25, height: 22)
    menuIcon.addTarget(self, action: #selector(didTapMenu), for: UIControlEvents.touchUpInside)
    self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: menuIcon), animated: false)
    
    let refreshIcon = UIButton()
    refreshIcon.setImage(UIImage(named: "refresh.png"), for: UIControlState.normal)
    refreshIcon.bounds = CGRect(x: 10, y: 0, width: 25, height: 25)
    refreshIcon.addTarget(self, action: #selector(didTapRefresh), for: UIControlEvents.touchUpInside)

    self.navigationItem.setRightBarButton(UIBarButtonItem(customView: refreshIcon), animated: false)
  }
  
  func didTapNextLevel() {
    _levelMenuController.goToNextLevel()
    reset()
  }
  
  func didTapMenu() {
    let navigationController = UINavigationController(rootViewController: _levelMenuController)
    self.present(navigationController, animated: true, completion: nil)
  }
  
  func didTapRefresh() {
    if (_gameModel.isWon() || _showedIsLostAlert) {
      self.reset()
    } else {
      self.showResetAlert(message: "Are you sure you want to reset?")
    }
  }
  
  func showResetAlert(message: String) {
    let alert = UIAlertController(title: nil,
                                  message: message,
                                  preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.destructive, handler: { (_ : UIAlertAction) -> Void in
      self.reset()
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func reset() {
    ResultController.writeResultToDatabase(level: _levelMenuController.currentLevel(),
                                           uniquePlayId: _uniquePlayId!,
                                           victory: _gameModel.isWon(),
                                           enoughPiecesLeft: _gameModel.isLost(),
                                           moves: _moves,
                                           initialShuffledPieces: _initialShuffledPieces)
    
    self.setupBoard()
    self.navigationItem.title = _gameModel._levelName
    _view.updateModel(_gameModel)
    _view._victoryView.isHidden = true
    _showedIsLostAlert = false
    _view._board.backgroundColor = BoardView.backgroundColor()

    _view.setNeedsLayout()
    _view.layoutIfNeeded()
  }
  
  func userDidPan(gesture: UIPanGestureRecognizer) {
    let minimumDistanceToConsider = CGFloat(3.0)
    let point = gesture.translation(in: _view)
    if abs(point.x) < minimumDistanceToConsider && abs(point.y) < minimumDistanceToConsider {
      return
    }
    
    var direction: Direction
    var distance = CGFloat(0.0)
    if _currentSwipeDirection == nil {
      if abs(point.y) > abs(point.x) {
        distance = abs(point.y)
        direction = point.y > 0 ? Direction.top : Direction.bottom
      } else {
        distance = abs(point.x)
        direction = point.x > 0 ? Direction.left : Direction.right
      }
    } else {
      direction = _currentSwipeDirection!
      switch direction {
      case .bottom:
        distance = abs(min(point.y, 0))
        break
      case .top:
        distance = max(point.y, 0)
        break
      case .left:
        distance = max(point.x, 0)
        break
      case .right:
        distance = abs(min(point.x, 0))
        break
      }
    }
    
    let movablePieceMask = _gameModel._board.findMovablePieces(swipeDirection: direction)
    
    if (gesture.state == UIGestureRecognizerState.ended) {
      _currentSwipeDirection = nil
      let velocity = gesture.velocity(in: _view)
      // Count it as a swipe
      if distance > 30.0 || distance > 20.0 && abs(velocity.x) + abs(velocity.y) > 500 {
        self.swipePieceOn(from: direction)
        
      // Revert to old position
      } else {
        UIView.animate(withDuration: 0.3, animations: {
          self._view._board.adjust(movablePieceMask: movablePieceMask, by: CGFloat(0.0), inDirection: direction)
        })
      }
    } else {
      _currentSwipeDirection = direction
      _view._board.adjust(movablePieceMask: movablePieceMask, by: min(distance, _view._board.singleSquareSize() * 0.8), inDirection: direction)
    }
  }

  func swipePieceOn(from:Direction) {
    _moves.append(from)
    
    let modelBeforeMove = _gameModel.copy()
    
    let piece: Piece = (_gameModel._pieces.last == nil) ? Piece.empty : _gameModel._pieces.last!

    // Eh shitty, but it works for now. Basic premise is to animate the rest of the distance the pieces on the board
    // need to move and then to slowly fade the new piece onto the board.
    //
    // Shortcomings:
    //  a) Doesn't account for initial velocity. Surprisingly hard, need to do some maths to go from gesture recognizer
    //     velocity to animate initalSpringVelocity
    //  b) Doesn't do anything special for stuff dropped in water (nor money in bank)
    //
    // Next piece we hide now and show after all the animations, I'd love to animate it back in but I can't get it to work :(
    _view._nextPieceView._piece?.isHidden = true
    _view.isUserInteractionEnabled = false

    let movablePieceMask = _gameModel._board.findMovablePieces(swipeDirection: from)
    let incrementedPieceMask = _gameModel._board.findIncrementedPieces(swipeDirection: from)
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   options: [UIViewAnimationOptions.curveLinear],
                   animations: {
                     self._view._board.adjust(movablePieceMask: movablePieceMask,
                                              by: self._view._board.singleSquareSize(),
                                              inDirection: from)
                   },
                   completion: { (completed) -> () in
                     let newPieceLocation: (Int, Int)? = self._gameModel._board.swipePieceOn(newPiece: piece, from: from)
                    
                    let modelBeforeAddingNewPiece = self._gameModel.copy()
                    
                     // Update the view with all the new locations but not the new piece,
                     // then we animate it on, then we update again
                     self.playAudioForChangesInState(oldModel: modelBeforeMove)
                     self._view.updateModel(self._gameModel)
                    
//                     UIView.animate(withDuration: 0.2,
//                                    animations: {
//                                      self._view._board.spinIn(pieceMask: incrementedPieceMask)
//                                    },
//                                    completion: nil)
                    
                     var newPieceView: PieceView? = nil
                     if (piece != Piece.empty && newPieceLocation != nil) {
                       let (newPieceColumn, newPieceRow) = newPieceLocation!
                       newPieceView = self._view._board.addPiece(piece: piece,
                                                                 row: newPieceRow,
                                                                 col: newPieceColumn)
                       newPieceView!.alpha = 0.0
                      
                       UIView.animate(withDuration: 0.4,
                                      animations:{
                                        newPieceView?.alpha = 1.0
                                      },
                                      completion: { (completed) in
                                        let _ = self._gameModel._pieces.popLast()
                                        self._gameModel._board.mergePiece(piece: piece,
                                                                          row: newPieceRow,
                                                                          column: newPieceColumn)
                                        self.playAudioForChangesInState(
                                          oldModel: modelBeforeAddingNewPiece
                                        )
                                        self._view.updateModel(self._gameModel)
                                        
                                        // testing
                                        self._view._board.spinIn(pieceMask: incrementedPieceMask)
                                        self._view.setNeedsLayout()
                                        self._view.layoutIfNeeded()
                                        
                                        self.completedSwipingPieceOn()
                                      })
                     } else {
                       self.completedSwipingPieceOn()
                     }
                   })
  }
  
  // Immediately upon updating the view with a new model this should be called as well
  // It determines the noises to be played and plays them.
  // Currently it is used twice, immediatley after the slide animation is completed and
  // immediately after the new piece is added to the board
  func playAudioForChangesInState(oldModel: GameModel) {
    if _gameModel.coinsLostToWaterCount(oldModel: oldModel) > 0 {
      NoiseEffectsController.playKerplunk()
    } else if _gameModel.coinsUsedInBanksCount(oldModel: oldModel) > 0 {
      NoiseEffectsController.playChaChing()
    }
  }
  
  func completedSwipingPieceOn() {
    _view._nextPieceView._piece?.isHidden = false
    _view.isUserInteractionEnabled = true
    
    // If they just won inform the level controller
    if _gameModel.isWon() && _view._victoryView.isHidden {
      _levelMenuController.userBeatLevel()
    }

    if _gameModel.isWon() {
      showVictoryView()
    }
    
    if _gameModel.isLost() && !_showedIsLostAlert {
      _view._board.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
      _showedIsLostAlert = true
      showResetAlert(message: "No remaining ways to win, would you like to reset?")
    }
  }
  
  func showVictoryView() {
    if _levelMenuController._currentRow == _levelMenuController._initialGameModels.count - 1 {
      _view._victoryView._nextLevelLabel.isHidden = true
    } else {
      _view._victoryView._nextLevelLabel.isHidden = false
    }
    
    _view._victoryView.isHidden = false
  }

  func setupBoard() {
    _uniquePlayId = UUID.init().uuidString
    _moves = [Direction]()
    _gameModel = _levelMenuController.currentLevel()
    // The pieces are popped off the back as the user plays so we reverse this list
    // which is used for the database
    _initialShuffledPieces = _gameModel._pieces.reversed()
  }
  
  // pragma mark - External Keyboard Support

  override var keyCommands: [UIKeyCommand]? {
    return [
      UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(arrowKeyTapped(sender:)), discoverabilityTitle: "Up Arrow"),
      UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: #selector(arrowKeyTapped(sender:)), discoverabilityTitle: "Right Arrow"),
      UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: #selector(arrowKeyTapped(sender:)), discoverabilityTitle: "Left Arrow"),
      UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(arrowKeyTapped(sender:)), discoverabilityTitle: "Down Arrow"),
    ]
  }
  
  func arrowKeyTapped(sender: UIKeyCommand) {
    if !_view.isUserInteractionEnabled {
      return
    }

    switch sender.input {
    case UIKeyInputUpArrow:
      self.swipePieceOn(from: Direction.bottom)
      break
    case UIKeyInputRightArrow:
      self.swipePieceOn(from: Direction.left)
      break
    case UIKeyInputLeftArrow:
      self.swipePieceOn(from: Direction.right)
      break
    case UIKeyInputDownArrow:
      self.swipePieceOn(from: Direction.top)
      break
    default:
      break
    }
  }
}
