//
//  ViewController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/16/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, LevelMenuControllerDelegate {
  var _board = Board()
  var _view: GameView
  var _pieces: [Piece] // The pieces in the order they will come out
  let _levelMenuController: LevelMenuController
  let _editGameViewController: EditGameViewController
  var _currentSwipeDirection: Direction?
  var _showedIsLostAlert = false
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    _view = GameView(frame:CGRect.zero)
    _pieces = [Piece]()
    _levelMenuController = LevelMenuController()
    _editGameViewController = EditGameViewController(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    _view = GameView(frame:CGRect.zero)
    _pieces = [Piece]()
    _levelMenuController = LevelMenuController()
    _editGameViewController = EditGameViewController(coder: aDecoder)!

    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _levelMenuController.delegate = self
    
    self.view = _view
    
    self.navigationItem.title = _levelMenuController.currentName()
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    
    // TODO, move menu buttons to navigationItem, lots of problems with custom icons though
//    let menuIcon = UIButton()
//    menuIcon.setImage(UIImage(named: "menu-icon.png"), for: UIControlState.normal)
//    menuIcon.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    menuIcon.addTarget(self, action: #selector(didTapMenu), for: UIControlEvents.touchUpInside)
//    self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: menuIcon), animated: true)
    
    _view._refreshButton.addTarget(self, action: #selector(didTapRefresh), for: UIControlEvents.touchUpInside)
    _view._editButton.addTarget(self, action: #selector(didTapEdit), for: UIControlEvents.touchUpInside)
    _view._menuIcon.addTarget(self, action: #selector(didTapMenu), for: UIControlEvents.touchUpInside)
    
    // Configure level menu controller
    _levelMenuController.configureWith(tableView: _view._levelMenu)
    
    // Configure edit game view controller
    _editGameViewController.levelMenuController = _levelMenuController
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(gesture:)))
    _view.addGestureRecognizer(panGesture)
    
    setupBoard()
    _view.update(board: _board._board, pieces: _pieces)
  }
  
  func didTapMenu() {
    _view._levelMenu.isHidden = !_view._levelMenu.isHidden
    _view.bringSubview(toFront: _view._levelMenu)
  }
  
  func didTapRefresh() {
    if (_board.isWon() || _showedIsLostAlert) {
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
  
  func didTapEdit() {
    self.navigationController?.pushViewController(_editGameViewController, animated: true)
  }
  
  func reset() {
    self.setupBoard()
    _view.update(board: _board._board, pieces: _pieces)
    _view._victoryLabel.isHidden = true
    _view._levelMenu.isHidden = true
    _showedIsLostAlert = false
    _view._board.backgroundColor = BoardView.backgroundColor()
  }
  
  func userDidPan(gesture: UIPanGestureRecognizer) {
    let minimumDistanceToConsider = CGFloat(3.0)
    let point = gesture.translation(in: _view)
    if point.x < minimumDistanceToConsider && point.x > -1 * minimumDistanceToConsider && point.y < minimumDistanceToConsider && point.y > -1 * minimumDistanceToConsider {
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
    
    let movablePieceMask = _board.findMovablePieces(swipeDirection: direction)
    
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
    var piece = _pieces.popLast()
    if piece == nil {
      piece = Piece.empty
    }

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

    let movablePieceMask = _board.findMovablePieces(swipeDirection: from)
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   options: [UIViewAnimationOptions.curveLinear],
                   animations: {
                     self._view._board.adjust(movablePieceMask: movablePieceMask,
                                              by: self._view._board.singleSquareSize(),
                                              inDirection: from)
                   },
                   completion: { (completed) -> () in
                     let newPieceLocation: (Int, Int)? = self._board.swipePieceOn(newPiece: piece!, from: from)
                    
                     // Update the view with all the new locations but not the new piece, then we animate it on,
                     // then we update again
                     self._view.update(board: self._board._board, pieces: self._pieces)
                    
                     var newPieceView: PieceView? = nil
                     if (piece != nil && newPieceLocation != nil) {
                       let (newPieceColumn, newPieceRow) = newPieceLocation!
                       newPieceView = self._view._board.addPiece(piece: piece!,
                                                                 row: newPieceRow,
                                                                 col: newPieceColumn)
                       newPieceView!.alpha = 0.0
                      
                       UIView.animate(withDuration: 0.4,
                                      animations:{
                                        newPieceView?.alpha = 1.0
                                      },
                                      completion: { (completed) in
                                        self._board.mergePiece(piece: piece!,
                                                               row: newPieceRow,
                                                               column: newPieceColumn)
                                        self._view.update(board: self._board._board, pieces: self._pieces)
                                        
                                        self.completedSwipingPieceOn()
                                      })
                     } else {
                       self.completedSwipingPieceOn()
                     }
                   })
  }
  
  func completedSwipingPieceOn() {
    _view._nextPieceView._piece?.isHidden = false
    _view.isUserInteractionEnabled = true
    
    if self._board.isWon() {
      self._view._victoryLabel.isHidden = false
    }
    
    if self._board.isLost(remainingCoins: self.remainingCoins()) && !_showedIsLostAlert {
      self._view._board.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
      _showedIsLostAlert = true
      self.showResetAlert(message: "No remaining ways to win, would you like to reset?")
    }
  }
  
  func remainingCoins() -> Int {
    var remainingCoins = 0
    for piece in _pieces {
      if piece.sameType(otherPiece: Piece.coins(1)) {
        remainingCoins += piece.value()
      }
    }
    return remainingCoins
  }

  func setupBoard() {
    do {
      _board = try Board(initialBoard: _levelMenuController.initialBoard())
      _pieces = shuffle(_levelMenuController.initialPieces())
    } catch {
      print("Can not initialize board")
    }
  }
  
  func shuffle(_ p: [Piece]) -> [Piece] {
    var pieces = p
    if pieces.count < 2 {
      return pieces
    }
    
    // Flip a coin to reserve or not if there are just two
    if pieces.count == 2 {
      return numericCast(arc4random_uniform(2)) == 1 ? pieces : pieces.reversed()
    }

    // For 3 or more we use https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    for i in 1...(pieces.count - 2) {
      let j = i + numericCast(arc4random_uniform(numericCast(pieces.count - i)))
      let swap = pieces[i]
      pieces[i] = pieces[j]
      pieces[j] = swap
    }
    return pieces
  }
}
