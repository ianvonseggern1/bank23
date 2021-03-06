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
  let _noiseEffectsController = NoiseEffectsController()
  let _bestTimeNetworker = BestTimeNetworker()

  var _timer = GameTimer()
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
    _levelMenuController._noiseEffectsController = _noiseEffectsController
    _levelMenuController._bestTimeNetworker = _bestTimeNetworker
    
    self.setupNavigationBarItems()
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(gesture:)))
    _view.addGestureRecognizer(panGesture)
    self.view = _view

    setupBoard()
    _view.updateModel(_gameModel)
    
    _view._timerView.setTime(time: 0)
    if UserController.getDefaultTimerModeOn() {
      let _ = _view._timerView.toggleShowTime()
    }
    
    _view._victoryView.isHidden = true
    let nextLevelTap = UITapGestureRecognizer(target: self, action: #selector(didTapNextLevel))
    _view._victoryView._nextLevelLabel.isUserInteractionEnabled = true
    _view._victoryView._nextLevelLabel.addGestureRecognizer(nextLevelTap)
    
    let timerViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapTimerView))
    _view._timerView.addGestureRecognizer(timerViewTap)
    
    self.navigationItem.title = _gameModel._levelName
  }
  
  func setupNavigationBarItems() {
    let menuIcon = UIButton()
    menuIcon.setImage(UIImage(named: "Menu.png"), for: UIControlState.normal)
    menuIcon.bounds = CGRect(x: 0, y: 0, width: 25, height: 22)
    menuIcon.addTarget(self,
                       action: #selector(didTapMenu),
                       for: UIControlEvents.touchUpInside)
    self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: menuIcon),
                                         animated: false)
    
    let refreshIcon = UIButton()
    refreshIcon.setImage(UIImage(named: "Refresh (1).png"), for: UIControlState.normal)
    refreshIcon.bounds = CGRect(x: 10, y: 0, width: 25, height: 25)
    refreshIcon.addTarget(self,
                          action: #selector(didTapRefresh),
                          for: UIControlEvents.touchUpInside)
    self.navigationItem.setRightBarButton(UIBarButtonItem(customView: refreshIcon),
                                          animated: false)
  }

// TODO pause timer when view isn't on screen
//  override func viewDidAppear(_ animated: Bool) {
//    if _timer.time() > 0 {
//      _timer.start()
//    }
//  }
//
//  override func viewDidDisappear(_ animated: Bool) {
//    _timer.pause()
//  }
  
  @objc func didTapNextLevel() {
    _levelMenuController.goToNextLevel()
    reset()
  }
  
  @objc func didTapTimerView() {
    let isOn = _view._timerView.toggleShowTime()
    UserController.setDefaultTimerMode(on: isOn)
    _view.setNeedsLayout()
    _view.setNeedsDisplay()
  }
  
  @objc func didTapMenu() {
    DispatchQueue.main.async {
      let navigationController = UINavigationController(rootViewController: self._levelMenuController)
      self.present(navigationController, animated: true, completion: nil)
    }
  }
  
  @objc func didTapRefresh() {
    if (_gameModel.isWon() || _showedIsLostAlert) {
      self.reset()
    } else {
      self.showResetAlert(message: "Are you sure you want to reset?", showCancel: true)
    }
  }
  
  func showResetAlert(message: String, showCancel: Bool) {
    let alert = UIAlertController(title: nil,
                                  message: message,
                                  preferredStyle: UIAlertControllerStyle.alert)
    if showCancel {
      alert.addAction(UIAlertAction(title: "Cancel",
                                    style: UIAlertActionStyle.cancel,
                                    handler: nil))
    }
    alert.addAction(UIAlertAction(title: "Reset",
                                  style: UIAlertActionStyle.destructive,
                                  handler: { (_ : UIAlertAction) -> Void in
      self.reset()
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func reset() {
    // Only record the game if its not won, if its won we already recorded it
    if (_moves.count > 0 && !_gameModel.isWon()) {
      ResultController.writeResultToDatabase(level: _levelMenuController.currentLevel(),
                                             uniquePlayId: _uniquePlayId!,
                                             victory: false,
                                             notEnoughPiecesLeft: _gameModel.isLost(),
                                             moves: _moves,
                                             initialShuffledPieces: _initialShuffledPieces,
                                             elapsedTime: _timer.time())
    }
    
    self.setupBoard()
    DispatchQueue.main.async {
      self.navigationItem.title = self._gameModel._levelName
      self._view.updateModel(self._gameModel)
      self._view._victoryView.isHidden = true
      self._showedIsLostAlert = false
      self._view._board.backgroundColor = BoardView.backgroundColor()

      self._view.setNeedsLayout()
      self._view.layoutIfNeeded()
    }
  }
  
  @objc func userDidPan(gesture: UIPanGestureRecognizer) {
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
  
  func startTimer() {
    _timer.start()
    
    _view._timerView.setTime(time: _timer.time())
    _view.setNeedsLayout()
    _view.setNeedsDisplay()
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
      self._view._timerView.setTime(time: self._timer.time())
      self._view._timerView.sizeToFit()
      self._view._timerView.setNeedsLayout()
      self._view._timerView.setNeedsDisplay()
    }
  }

  func swipePieceOn(from:Direction) {
    if _moves.count == 0 {
      startTimer()
    }
    
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
                     let playedNoise = self.playAudioForChangesInState(oldModel: modelBeforeMove, playSlide: false)
                     // Pop piece after determining audio changes, but before updating view
                     let _ = self._gameModel._pieces.popLast()
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
                      
                       UIView.animate(withDuration: 0.2,
                                      animations:{
                                        newPieceView?.alpha = 1.0
                                      },
                                      completion: { (completed) in
                                        self._gameModel._board.mergePiece(piece: piece,
                                                                          row: newPieceRow,
                                                                          column: newPieceColumn)
                                        let _ = self.playAudioForChangesInState(
                                          oldModel: modelBeforeAddingNewPiece,
                                          playSlide: !playedNoise
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
  // Currently it is used twice, immediately after the slide animation is completed and
  // immediately after the new piece is added to the board
  // Returns true if a noise was played
  func playAudioForChangesInState(oldModel: GameModel, playSlide: Bool) -> Bool {
    if _gameModel.coinsLostToWaterCount(oldModel: oldModel) > 0 {
      _noiseEffectsController.playKerplunk()
    } else if _gameModel.coinsUsedInBanksCount(oldModel: oldModel) > 0 {
      _noiseEffectsController.playChaChing()
    } else if _gameModel.sandFilledInWaterCount(oldModel: oldModel) > 0 {
      _noiseEffectsController.playSwish()
    } else if (playSlide) {
      _noiseEffectsController.playSlide()
    } else {
      return false
    }
    return true
  }
  
  func completedSwipingPieceOn() {
    _view._nextPieceView._piece?.isHidden = false
    _view.isUserInteractionEnabled = true
    
    // If they just won inform the level controller
    if _gameModel.isWon() && _view._victoryView.isHidden {
      _timer.pause()
      let elapsedTime = _timer.time()
      let initialLevelModel = _levelMenuController.currentLevel()
      let isUsersFastestTime = _levelMenuController.userBeatLevel(elapsedTime: elapsedTime)
      var isRecord = false
      
      // If its not the best time ever we don't need to do anything
      // We also don't want to store this time if its a user created level
      let bestTime = _bestTimeNetworker.getBestTimeFor(level: initialLevelModel)
      if (
        _gameModel._levelType == LevelType.Server &&
        (bestTime != nil && bestTime!.time > elapsedTime)
      ) {
        isRecord = true
        
        // If the user lacks a real username prompt them to provide one before
        // attempting to record record
        let username = UserController.getUsername()
        if username == nil || username! == "" {
          promptForUsernameAndCallBestTimeNetworker()
        } else {
          callBestTimeNetworkerWithResult()
        }
      }
      
      ResultController.writeResultToDatabase(level: initialLevelModel,
                                             uniquePlayId: _uniquePlayId!,
                                             victory: true,
                                             notEnoughPiecesLeft: false,
                                             moves: _moves,
                                             initialShuffledPieces: _initialShuffledPieces,
                                             elapsedTime: elapsedTime)
      showVictoryView(isUsersFastestTime: isUsersFastestTime, isRecord: isRecord)
    }
    
    if _gameModel.isLost() && !_showedIsLostAlert {
      _view._board.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
      _showedIsLostAlert = true
      showResetAlert(message: "Uh oh, looks like you dropped too many coins into the water traps!\nThere are no longer enough remaining coins to win.",
                     showCancel: false)
    }
  }
  
  // For now this is just used if they don't have a username
  // Might update to use in all cases
  func promptForUsernameAndCallBestTimeNetworker() {
    let createUsernameAlert = UIAlertController(
      title: "Wow!",
      message: "That was fast, looks like you set the record time! Please enter a nickname to be displayed. In the future you can change your name at the top of the menu.",
      preferredStyle: .alert)
    createUsernameAlert.addTextField { (textField) in
      textField.placeholder = "Username"
      textField.textAlignment = .center
    }
    createUsernameAlert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (alert) in
      let textField = createUsernameAlert.textFields![0] as UITextField
      if let newName = textField.text {
        UserController.setUsername(newName)
      }
      self.callBestTimeNetworkerWithResult()
    }))
    self.present(createUsernameAlert, animated: true, completion: nil)
  }
  
  func alertFailedUpdateBestTime() {
    let alert = UIAlertController(title: nil,
                                  message: "Failed to save best time",
                                  preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Skip",
                                  style: UIAlertActionStyle.cancel,
                                  handler: nil))
    alert.addAction(UIAlertAction(title: "Try Again",
                                  style: UIAlertActionStyle.default,
                                  handler: { (_ : UIAlertAction) -> Void in
                                    self.callBestTimeNetworkerWithResult()
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func callBestTimeNetworkerWithResult() {
    self._bestTimeNetworker.userCompletedLevelWithTime(level: self._levelMenuController.currentLevel(),
                                                       elapsedTime: self._timer.time(),
                                                       playID: self._uniquePlayId!,
                                                       updateSuccesful: self._levelMenuController.reload,
                                                       updateFailed: self.alertFailedUpdateBestTime)
  }
  
  func showVictoryView(isUsersFastestTime: Bool, isRecord: Bool) {
    DispatchQueue.main.async {
      self._view._victoryView.setTimeElapsed(time: self._timer.time(),
                                             isUsersFastestTime: isUsersFastestTime,
                                             isRecord: isRecord)
      self._view._victoryView._nextLevelLabel.isHidden = self._levelMenuController.currentLevelIsLast()
      self._view._victoryView.sizeToFit()
      self._view._victoryView.isHidden = false
    }
  }

  func setupBoard() {
    _uniquePlayId = UUID.init().uuidString
    _moves = [Direction]()
    _gameModel = _levelMenuController.currentLevel()
    _timer = GameTimer()
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
  
  @objc func arrowKeyTapped(sender: UIKeyCommand) {
    if !_view.isUserInteractionEnabled {
      return
    }

    switch sender.input {
    case UIKeyInputUpArrow?:
      self.swipePieceOn(from: Direction.bottom)
      break
    case UIKeyInputRightArrow?:
      self.swipePieceOn(from: Direction.left)
      break
    case UIKeyInputLeftArrow?:
      self.swipePieceOn(from: Direction.right)
      break
    case UIKeyInputDownArrow?:
      self.swipePieceOn(from: Direction.top)
      break
    default:
      break
    }
  }
}
