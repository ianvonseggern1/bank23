//
//  LevelMenuController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/26/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import FacebookCore

let LEVEL_ROW_VIEW_HEIGHT = 110

protocol LevelMenuControllerDelegate: NSObjectProtocol {
  // TODO, update to explictly pass newly selected level here
  // rather than creating a hidden dependency on setting it first
  func reset()
}

public class LevelMenuController:
  UIViewController,
  UITableViewDataSource,
  UITableViewDelegate,
  UITextFieldDelegate,
  EditGameViewControllerDelegate,
  LevelMenuRowActionControllerDelegate
{
  weak var delegate: LevelMenuControllerDelegate?
  
  // Created by ViewController
  var _noiseEffectsController: NoiseEffectsController?
  var _bestTimeNetworker: BestTimeNetworker?

  let _editGameViewController = EditGameViewController()
  let _userController = UserController()
  let _resultController = ResultController()
  var _actionSheetController: LevelMenuRowActionController?

  var _gameModels = [GameModel]()

  var _tableView = UITableView()
  let _usernameTextField = UITextField()
  let _aboutLabel = UILabel()
  let _aboutExplanation = UILabel()
  
  var _loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
  
  var _currentRow = 0
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(_tableView)
    _tableView.frame = self.view.bounds
    _tableView.dataSource = self
    _tableView.delegate = self
    
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(gesture:)))
    _tableView.addGestureRecognizer(gesture)
    
    _aboutExplanation.isHidden = true
    
    _editGameViewController.delegate = self
    
    setupNavigationBar()
  }
  
  func setupNavigationBar() {
    self.navigationItem.title = "Main Menu"

    let button = UIBarButtonItem(image: UIImage(named: "Close.png"),
                                 style: .done,
                                 target: self,
                                 action: #selector(didTapXOut))
    button.tintColor = UIColor.darkGray
    self.navigationItem.setLeftBarButton(button, animated: false)
    
    setAudioButtonTitle()
  }
  
  @objc public func didLongPress(gesture: UIPanGestureRecognizer) {
    if gesture.state != UIGestureRecognizerState.began {
      return
    }
    
    let location = gesture.location(in: _tableView)
    let indexPath = _tableView.indexPathForRow(at: location)
    if indexPath == nil || indexPath!.section != 1 {
      return
    }
    
    let selectedLevel = _gameModels[indexPath!.row]
    _actionSheetController = LevelMenuRowActionController(level: selectedLevel)
    _actionSheetController!.delegate = self
    self.present(_actionSheetController!._levelActionSheet,
                 animated: true,
                 completion: nil)
  }

  public func fetchLevels() {
    // Built In Levels
    //_gameModels.append(contentsOf: BuiltInLevels.get())
    // User Created Levels
    _gameModels.append(contentsOf: LevelController.getLocalLevels())
    // Levels from Server
    LevelController.getAllBoardsFromDatabase(boardCallback: self.addAllAndReloadCurrentGame)
  }

  public func currentLevel() -> GameModel {
    if _gameModels.count > 0 {
      return _gameModels[_currentRow].copy()
    }
    return try! GameModel(name: "",
                          collapsedPieces: [],
                          initialBoard: Array.init(repeating:Array.init(repeating: Piece.empty,
                                                                        count: 5),
                                                   count: 5))
  }
  
  public func currentLevelIsLast() -> Bool {
    return _currentRow == (_gameModels.count - 1)
  }
  
  public func add(level: GameModel) {
    _gameModels.append(level)
    sortGames()
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
  }
  
  public func sortGames() {
    _gameModels.sort(by: {
      ($0._sortKey == $1._sortKey)
        ? ($0._levelName < $1._levelName)
        : ($0._sortKey < $1._sortKey)
    })
  }
  
  public func addAllAndReloadCurrentGame(levels: [GameModel]) {
    _gameModels.append(contentsOf: levels)
    sortGames()
    
    if let currentLevel = UserController.getCurrentLevelHash() {
      if let currentRow = findRowForLevelHash(levelHash: currentLevel) {
        _currentRow = currentRow
      }
    }
    
    DispatchQueue.main.async {
      self._tableView.reloadData()
      self.delegate?.reset()
    }
  }
  
  public func reload() {
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
  }
  
  public func findRowForLevelHash(levelHash: String) -> Int? {
    for (index, game) in _gameModels.enumerated() {
      if String(game.hash()) == levelHash {
        return index
      }
    }
    return nil
  }
  
  @objc func didTapXOut() {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @objc func didTapAudioToggle() {
    _noiseEffectsController!.toggleAudio()
    setAudioButtonTitle()
  }
  
  func setAudioButtonTitle() {
    let buttonName = _noiseEffectsController!.audioOn ? "Sound On.png" : "Sound Off.png"
    let button = UIBarButtonItem(image: UIImage(named: buttonName),
                                 style: .done,
                                 target: self,
                                 action: #selector(didTapAudioToggle))
    button.tintColor = UIColor.darkGray
    self.navigationItem.setRightBarButton(button, animated: false)
  }
  
  public func goToNextLevel() {
    if (_currentRow < _gameModels.count) {
      setCurrentRow(row: _currentRow + 1)
    } else {
      NSLog("Can't go to next level, this is the last one")
    }
  }
  
  // Stores this to user defaults in addition to setting it
  func setCurrentRow(row: Int) {
    let newLevel = _gameModels[row]
    UserController.setCurrentLevel(level: newLevel)
    _currentRow = row
    
    DispatchQueue.main.async {
      self._tableView.reloadData()
      
      // We need to make sure the table exists and as a sanity check we make sure that current row is
      // in bounds of the data source
      if self._tableView.dataSource != nil && self._gameModels.count > self._currentRow {
        self._tableView.scrollToRow(at: IndexPath(row: self._currentRow, section: 1),
                                    at: .middle,
                                    animated: false)
      }
    }
  }
  
  public func userBeatLevel(elapsedTime: Int) -> Bool {
    let isFastestTime = _resultController.userBeatlevel(level: currentLevel(),
                                                        elapsedTime: elapsedTime)
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
    return isFastestTime
  }
  
  // LevelMenuRowActionControllerDelegate
  
  func openInGameEditor(level: GameModel) {
    _editGameViewController.setModel(model: level)
    self.navigationController?.pushViewController(_editGameViewController, animated: true)
  }
  
  func deleteLevel(_ level: GameModel) {
    LevelController.removeLocalLevel(toRemove: level)
    if let levelRow = findRowForLevelHash(levelHash: String(level.hash())) {
      _gameModels.remove(at: levelRow)
    }
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
  }
  
  func presentEditSortKeyAlert(_ alert: UIAlertController) {
    self.present(alert, animated: true)
  }
  
  func sortKeyUpdated() {
    sortGames()
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
  }
  
  // UITableViewDataSource
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return _gameModels.count
    } else if section == 2 {
      return 1
    } else if section == 3 {
      return 1
    }
    return 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableViewCell = UITableViewCell()
    tableViewCell.selectionStyle = UITableViewCellSelectionStyle.none
    tableViewCell.preservesSuperviewLayoutMargins = false
    tableViewCell.separatorInset = UIEdgeInsets.zero
    tableViewCell.layoutMargins = UIEdgeInsets.zero

    if indexPath.section == 0 {
      let usernameLabel = UILabel()
      usernameLabel.text = "Your Username: "
      usernameLabel.sizeToFit()
      usernameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
      usernameLabel.textColor = UIColor.darkGray
      usernameLabel.frame = CGRect(x: 10,
                                   y: 10,
                                   width: usernameLabel.frame.width,
                                   height: usernameLabel.frame.height)
      tableViewCell.addSubview(usernameLabel)

      if _usernameTextField.text == nil || _usernameTextField.text == "" {
        _usernameTextField.text = UserController.getUsername()
      }
      _usernameTextField.placeholder = "Tap to enter"
      _usernameTextField.returnKeyType = UIReturnKeyType.done
      _usernameTextField.delegate = self
      _usernameTextField.frame = CGRect(x: usernameLabel.frame.maxX,
                                       y: 10,
                                       width: tableView.frame.width - usernameLabel.frame.maxX - 10,
                                       height: usernameLabel.frame.height)
      tableView.addSubview(_usernameTextField)
      
      // TODO decide on using this
//      _loginButton.sizeToFit()
//      _loginButton.frame = CGRect(x: 10,
//                                  y: 10,
//                                  width: _loginButton.frame.width,
//                                  height: _loginButton.frame.height)
//      _loginButton.delegate = _userController
//      tableViewCell.addSubview(_loginButton)
    } else if indexPath.section == 1 {
      let model = _gameModels[indexPath.row]
      let bestTime = _bestTimeNetworker!.getBestTimeFor(level: model)
      let levelRowCell = LevelMenuLevelRowView(gameModel: model,
                                               levelBeatenTime: _resultController.levelBestTime(model),
                                               bestTimeInfo: bestTime)
      levelRowCell.frame = CGRect(x: 0, y: 0, width: Int(tableView.frame.width), height: LEVEL_ROW_VIEW_HEIGHT)
      
      if _currentRow == indexPath.row {
        //levelRowCell.backgroundColor = BoardView.backgroundColor()
        //levelRowCell._boardView.backgroundColor = UIColor.white
        levelRowCell._currentLevelView.isHidden = false
      }
      
      tableViewCell.addSubview(levelRowCell)

    } else if indexPath.section == 2 {
      let label = UILabel()
      label.text = "+ Add a Level"
      label.font = UIFont.boldSystemFont(ofSize: 16.0)
      label.textColor = UIColor.darkGray
      label.sizeToFit()
      label.frame = CGRect(x: 30,
                           y: 10,
                           width: label.frame.width,
                           height: label.frame.height)
      tableViewCell.addSubview(label)
    } else if indexPath.section == 3 {
      _aboutLabel.text = "About"
      _aboutLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
      _aboutLabel.sizeToFit()
      _aboutLabel.frame = CGRect(x: 10,
                                 y: 10,
                                 width: _aboutLabel.frame.width,
                                 height: _aboutLabel.frame.height)
      tableViewCell.addSubview(_aboutLabel)
      
      _aboutExplanation.font = UIFont.boldSystemFont(ofSize: 12.0)
      _aboutExplanation.textColor = UIColor.darkGray
      _aboutExplanation.textAlignment = NSTextAlignment.center
      _aboutExplanation.numberOfLines = 0
      var explanation = ""
      explanation += "Version 1.0\n\n"
      explanation += "Welcome to Bank 23. This is the first release and probably contains lots of bugs, so sorry for any frustration and please report them to me :) It's also a work in progress, so also feel free to let me know what you would like to see added and what isn't currently working for you. Thanks for playing!\n\n"
      explanation += "Credits\nSabrina Siu created all the (very cute) pieces, icons, and most of the design. She's also thought through many different user flows and experiences, as well as spent hours providing general advice. Plus she has lots of ideas on deck that I haven't had time to implement yet.\nMe (Ian Vonseggern), I've spent years playing simple cell phone games and decided I wanted to create one instead of just playing existing ones. I wanted to create a game that involved treasure and goals, that had a simple design, but from which complex strategy emerged. I also wanted to try out Swift, which I've built this entirely in (and I want to mention how much I like this language). I created this game on a plane, typed the name Bank into XCode, and I'm not sure how I typed the 23, but I think it might have been my elbow. Anyway I like it, so here's Bank 23.\n\n"
      explanation += "Copyright 2017. All rights reserved."
      _aboutExplanation.text = explanation
      let explanationSize = _aboutExplanation.sizeThatFits(CGSize(width: tableView.frame.width - 20,
                                                                  height: CGFloat.greatestFiniteMagnitude))
      _aboutExplanation.frame = CGRect(x: 10,
                                       y: 40,
                                       width: tableView.frame.width - 20,
                                       height: explanationSize.height)
      tableViewCell.addSubview(_aboutExplanation)
    }

    return tableViewCell
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    } else if indexPath.section == 1 {
      return CGFloat(LEVEL_ROW_VIEW_HEIGHT)
    } else if indexPath.section == 3 {
      return _aboutExplanation.isHidden ? 40 : 40 + _aboutExplanation.frame.height + 10
    }
    return 40
  }
  
  // UITableViewDelegate
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      _usernameTextField.becomeFirstResponder()
      return
    }
    
    if _usernameTextField.isFirstResponder {
      enteredUsername(_usernameTextField.text!)
      return
    }
    
    if indexPath.section == 1 {
      if indexPath.row != _currentRow {
        setCurrentRow(row: indexPath.row)
        delegate?.reset()
      }
      self.dismiss(animated: true, completion: nil)
    
    } else if indexPath.section == 2 {
      self.navigationController?.pushViewController(_editGameViewController, animated: true)
    } else if indexPath.section == 3 {
      _aboutExplanation.isHidden = !_aboutExplanation.isHidden
      tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
      tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
  }
  
  // UITextFieldDelegate
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    enteredUsername(textField.text!)
    return true
  }
  
  private func enteredUsername(_ username: String?) {
    if username != nil {
      UserController.setUsername(username!)
    }
    _usernameTextField.resignFirstResponder()
  }
}
