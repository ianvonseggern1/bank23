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

public class LevelMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EditGameViewControllerDelegate {
  
  weak var delegate: LevelMenuControllerDelegate?
  
  // Created by ViewController
  var _noiseEffectsController: NoiseEffectsController?
  var _bestTimeNetworker: BestTimeNetworker?

  let _editGameViewController = EditGameViewController()
  let _userController = UserController()
  let _resultController = ResultController()

  var _gameModels = [GameModel]()

  var _tableView = UITableView()
  let _usernameTextField = UITextField()
  let _aboutLabel = UILabel()
  let _aboutExplanation = UILabel()
  
  let _levelActionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
  var _deleteAction: UIAlertAction? = nil
  var _longPressSelectedRow: Int? = nil
  
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
    setupLevelActionSheet()
  }
  
  func setupNavigationBar() {
    self.navigationItem.title = "Main Menu"
    
    let xOutIcon = UIButton()
    xOutIcon.setImage(UIImage(named: "cross.png"), for: UIControlState.normal)
    xOutIcon.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
    xOutIcon.addTarget(self, action: #selector(didTapXOut), for: UIControlEvents.touchUpInside)
    self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: xOutIcon), animated: false)
    
    setAudioButtonTitle()
  }
  
  func setupLevelActionSheet() {
    _levelActionSheet.addAction(UIAlertAction(title: "Open in Editor",
                                              style: .default,
                                              handler: { (action) in self.openSelectedLevelInEditor()}))
    
    if (ADMIN_MODE) {
      _levelActionSheet.addAction(UIAlertAction(title: "Save to Database",
                                                style: .default,
                                                handler: { (action) in
                                                  self.saveLocalLevelToDatabase()}))
    }
    
    _deleteAction = UIAlertAction(title: "Delete",
                                  style: .destructive,
                                  handler: { (action) in self.removeSelectedLevel() })
    _levelActionSheet.addAction(_deleteAction!)
    _levelActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
    
    let model = _gameModels[indexPath!.row]
    _deleteAction!.isEnabled = model._levelType == LevelType.UserCreated
    _longPressSelectedRow = indexPath!.row
    self.present(_levelActionSheet, animated: true, completion: nil)
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
  
  public func removeSelectedLevel() {
    LevelController.removeLocalLevel(toRemove: _gameModels[_longPressSelectedRow!])
    _gameModels.remove(at: _longPressSelectedRow!)
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
    _longPressSelectedRow = nil
  }
  
  public func openSelectedLevelInEditor() {
    let model = _gameModels[_longPressSelectedRow!]
    _editGameViewController.setModel(model: model)
    self.navigationController?.pushViewController(_editGameViewController, animated: true)
  }
  
  func saveLocalLevelToDatabase() {
    let model = _gameModels[_longPressSelectedRow!]
    do {
      try LevelController.writeLocalLevelToMainGameDatabase(level: model)
    } catch {
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
    let title = _noiseEffectsController!.audioOn ? "Audio On" : "Audio Off"
    self.navigationItem.setRightBarButton(UIBarButtonItem(title: title,
                                                          style: UIBarButtonItemStyle.plain,
                                                          target: self,
                                                          action: #selector(didTapAudioToggle)),
                                          animated: false)
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
  }
  
  public func userBeatLevel(elapsedTime: Int) -> Bool {
    let isFastestTime = _resultController.userBeatlevel(level: currentLevel(),
                                                        elapsedTime: elapsedTime)
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
    return isFastestTime
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

    if indexPath.section == 0 {
      // TODO remove username text field
//      let usernameLabel = UILabel()
//      usernameLabel.text = "Your Username: "
//      usernameLabel.sizeToFit()
//      usernameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
//      usernameLabel.textColor = UIColor.darkGray
//      usernameLabel.frame = CGRect(x: 10,
//                                   y: 10,
//                                   width: usernameLabel.frame.width,
//                                   height: usernameLabel.frame.height)
//      tableViewCell.addSubview(usernameLabel)
//
//      if _usernameTextField.text == nil || _usernameTextField.text == "" {
//        _usernameTextField.text = UserController.getUsername()
//      }
//      _usernameTextField.placeholder = "Tap to enter"
//      _usernameTextField.returnKeyType = UIReturnKeyType.done
//      _usernameTextField.delegate = self
//      _usernameTextField.frame = CGRect(x: usernameLabel.frame.maxX,
//                                       y: 10,
//                                       width: tableView.frame.width - usernameLabel.frame.maxX - 10,
//                                       height: usernameLabel.frame.height)
      
      _loginButton.sizeToFit()
      _loginButton.frame = CGRect(x: 10,
                                  y: 10,
                                  width: _loginButton.frame.width,
                                  height: _loginButton.frame.height)
      _loginButton.delegate = _userController
      tableViewCell.addSubview(_loginButton)
    } else if indexPath.section == 1 {
      let model = _gameModels[indexPath.row]
      let bestTime = _bestTimeNetworker!.getBestTimeFor(level: model)
      let levelRowCell = LevelMenuLevelRowView(gameModel: model,
                                               levelBeatenTime: _resultController.levelBestTime(model),
                                               bestTimeInfo: bestTime)
      levelRowCell.frame = CGRect(x: 0, y: 0, width: Int(tableView.frame.width), height: LEVEL_ROW_VIEW_HEIGHT)
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
      explanation += "Version 0.0\n\n"
      explanation += "Welcome to the alpha of Bank 23. This is the first release and probably contains lots of bugs, so sorry for any frustration and please report them to me :) It also is very bare bones (currently), so also feel free to let me know what you would like to see added and what isn't currently working for you. Thanks for test driving!\n\n"
      explanation += "Credits\nSabrina Siu created all the (very cute) pieces and much of the design (the good looking parts anyway). She's also thought through many different user flows and experiences, as well as spent hours providing general advice. Plus she has lots of ideas on deck that I haven't had time to implement yet.\nIan Vonseggern, well since this is first person - me, I've spent years playing simple cell phone games and decided I wanted to create one instead of just playing existing ones. I wanted to create a game that involved treasure and goals, that had a simple design, but from which complex strategy emerged. I had a bunch of different ideas, but decided this would be a relatively easy one to prototype and so far I'm really enjoying playing it. I also wanted to try out Swift, which I've built this entirely in (and I want to mention how much I like this language). I created this game on a plane, typed the name Bank into XCode, and I'm not sure how I typed the 23, but I think it might have been my elbow. Anyway I like it, so here's Bank 23.\n\n"
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
      return 50
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
      setCurrentRow(row: indexPath.row)
      delegate?.reset()
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
