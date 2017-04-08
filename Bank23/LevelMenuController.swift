//
//  LevelMenuController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/26/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

protocol LevelMenuControllerDelegate: NSObjectProtocol {
  func reset()
}

public class LevelMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EditGameViewControllerDelegate {
  weak var delegate: LevelMenuControllerDelegate?

  let _editGameViewController = EditGameViewController()

  var _initialGameModels = [GameModel]()

  var _tableView = UITableView()
  let _usernameTextField = UITextField()
  let _aboutLabel = UILabel()
  let _aboutExplanation = UILabel()
  
  var _currentRow = 0
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(_tableView)
    _tableView.frame = self.view.bounds
    _tableView.dataSource = self
    _tableView.delegate = self
    
    _aboutExplanation.isHidden = true
    
    _editGameViewController.delegate = self
    
    // Setup Navigation Bar

    self.navigationItem.title = "Main Menu"
    
    let menuIcon = UIButton()
    menuIcon.setImage(UIImage(named: "cross.png"), for: UIControlState.normal)
    menuIcon.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
    menuIcon.addTarget(self, action: #selector(didTapMenu), for: UIControlEvents.touchUpInside)
    self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: menuIcon), animated: false)
  }

  public func fetchLevels() {
    addLocalLevels()
    LevelNetworker.getAllBoardsFromDatabase(boardCallback: self.addAllAndReloadCurrentGame)
  }

  public func currentLevel() -> GameModel {
    return _initialGameModels[_currentRow].copy()
  }
  
  public func add(level: GameModel) {
    _initialGameModels.append(level)
    _initialGameModels.sort(by: { $0._levelName < $1._levelName })
    DispatchQueue.main.async {
      self._tableView.reloadData()
    }
  }
  
  public func addAllAndReloadCurrentGame(levels: [GameModel]) {
    _initialGameModels.append(contentsOf: levels)
    _initialGameModels.sort(by: { $0._levelName < $1._levelName })
    DispatchQueue.main.async {
      self._tableView.reloadData()
      self.delegate?.reset()
    }
  }
  
  func didTapMenu() {
    self.dismiss(animated: true, completion: nil)
  }
  
  func addLocalLevels() {
    // Helpful reminder board is indexed first by column, then row i.e. board[column][row]
    
    // Level 1
    var initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][3] = Piece.bank(10)
    initialBoard[1][2] = Piece.water(2)
    initialBoard[3][2] = Piece.water(2)
    initialBoard[1][3] = Piece.water(5)
    initialBoard[3][3] = Piece.water(5)
    initialBoard[1][4] = Piece.water(3)
    initialBoard[3][4] = Piece.water(3)
    
    var initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "The Narrows",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 2
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][2] = Piece.bank(10)
    initialBoard[1][2] = Piece.water(5)
    initialBoard[3][2] = Piece.water(5)
    initialBoard[2][3] = Piece.water(5)
    initialBoard[2][1] = Piece.water(5)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "The Island",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 3
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][4] = Piece.bank(10)
    initialBoard[1][4] = Piece.water(8)
    initialBoard[3][4] = Piece.water(8)
    initialBoard[2][3] = Piece.water(4)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "Top Side",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 4
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[4][4] = Piece.bank(10)
    initialBoard[4][3] = Piece.water(10)
    initialBoard[3][4] = Piece.water(10)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "Corner Case",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 5
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][2] = Piece.bank(10)
    initialBoard[1][1] = Piece.water(2)
    initialBoard[3][1] = Piece.water(2)
    initialBoard[1][2] = Piece.water(3)
    initialBoard[3][2] = Piece.water(3)
    initialBoard[1][3] = Piece.water(3)
    initialBoard[3][3] = Piece.water(3)
    initialBoard[1][4] = Piece.water(2)
    initialBoard[3][4] = Piece.water(2)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "The Narrows Part II",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 6
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[0][2] = Piece.bank(5)
    initialBoard[4][2] = Piece.bank(5)
    initialBoard[0][1] = Piece.water(3)
    initialBoard[0][3] = Piece.water(3)
    initialBoard[1][2] = Piece.water(4)
    initialBoard[4][1] = Piece.water(3)
    initialBoard[4][3] = Piece.water(3)
    initialBoard[3][2] = Piece.water(4)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "Worlds Apart",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 7
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[1][2] = Piece.bank(5)
    initialBoard[3][2] = Piece.bank(5)
    initialBoard[1][1] = Piece.water(3)
    initialBoard[1][3] = Piece.water(3)
    initialBoard[3][1] = Piece.water(3)
    initialBoard[3][3] = Piece.water(3)
    initialBoard[2][1] = Piece.water(3)
    initialBoard[2][2] = Piece.water(2)
    initialBoard[2][3] = Piece.water(3)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "Split Brain",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 8
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:7), count:7)
    initialBoard[3][3] = Piece.bank(16)
    initialBoard[3][2] = Piece.water(4)
    initialBoard[3][4] = Piece.water(4)
    initialBoard[2][3] = Piece.water(4)
    initialBoard[4][3] = Piece.water(4)
    initialBoard[1][2] = Piece.water(2)
    initialBoard[5][2] = Piece.water(2)
    initialBoard[2][1] = Piece.water(2)
    initialBoard[2][5] = Piece.water(2)
    initialBoard[4][1] = Piece.water(2)
    initialBoard[4][5] = Piece.water(2)
    initialBoard[1][4] = Piece.water(2)
    initialBoard[5][4] = Piece.water(2)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(16))
    initialPieces.append(Piece.sand(32))
    
    _initialGameModels.append(try! GameModel(name: "007",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    // Level 9
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:7), count:7)
    initialBoard[2][6] = Piece.mountain(1)
    initialBoard[2][5] = Piece.mountain(1)
    initialBoard[2][4] = Piece.mountain(1)
    initialBoard[2][3] = Piece.mountain(1)
    initialBoard[2][2] = Piece.mountain(1)
    initialBoard[2][1] = Piece.mountain(1)
    initialBoard[4][6] = Piece.mountain(1)
    initialBoard[4][5] = Piece.mountain(1)
    initialBoard[4][4] = Piece.mountain(1)
    initialBoard[4][3] = Piece.mountain(1)
    initialBoard[4][2] = Piece.mountain(1)
    initialBoard[4][1] = Piece.mountain(1)
    initialBoard[1][2] = Piece.mountain(1)
    initialBoard[1][5] = Piece.mountain(1)
    initialBoard[5][2] = Piece.mountain(1)
    initialBoard[5][5] = Piece.mountain(1)
    
    initialBoard[1][1] = Piece.water(4)
    initialBoard[1][4] = Piece.water(4)
    initialBoard[5][1] = Piece.water(4)
    initialBoard[5][4] = Piece.water(4)
    initialBoard[3][3] = Piece.water(4)
    
    initialBoard[3][2] = Piece.bank(5)
    initialBoard[3][4] = Piece.bank(5)
    
    initialPieces = [Piece]()
    initialPieces.append(Piece.coins(10))
    initialPieces.append(Piece.sand(20))
    
    _initialGameModels.append(try! GameModel(name: "Grand Canyon",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
  }
  
  // UITableViewDataSource
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return _initialGameModels.count
    } else if section == 2 {
      return 1
    } else if section == 3 {
      return 1
    }
    return 0
  }
  
  // TODO create seperate views for these
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableViewCell = UITableViewCell()
    tableViewCell.selectionStyle = UITableViewCellSelectionStyle.none

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
      tableViewCell.addSubview(_usernameTextField)
    } else if indexPath.section == 1 {
      let gameModel = _initialGameModels[indexPath.row]
      
      let levelName = UILabel()
      levelName.text = gameModel._levelName
      levelName.font = UIFont.boldSystemFont(ofSize: 16.0)
      levelName.sizeToFit()
      levelName.frame = CGRect(x: 10,
                           y: 10,
                           width: levelName.frame.width,
                           height: levelName.frame.height)
      tableViewCell.addSubview(levelName)
      
      if gameModel._creatorName != nil {
        let creatorName = UILabel()
        creatorName.text = "Created by ".appending(gameModel._creatorName!)
        creatorName.font = UIFont.systemFont(ofSize: 12.0)
        creatorName.textColor = UIColor.gray
        creatorName.sizeToFit()
        creatorName.frame = CGRect(x: 10,
                                   y: levelName.frame.maxY,
                                   width: creatorName.frame.width,
                                   height: creatorName.frame.height)
        tableViewCell.addSubview(creatorName)
      }
      
      let boardView = BoardView(frame: CGRect(x: self._tableView.frame.width - 100,
                                              y: 10,
                                              width: 90,
                                              height: 90))
      boardView.showCountLabels = false
      boardView.updateModel(board: _initialGameModels[indexPath.row]._board._board)
      tableViewCell.addSubview(boardView)
    
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
      explanation += "Credits\nSabrina Siu created all the (very cute) peices and much of the design (the good looking parts anyway). See's also thought through many different user flows and experiences, as well as spent hours providing general advice. Plus she has lots of ideas on deck that I haven't had time to implement yet.\nIan Vonseggern, well since this is first person - me, I've spent years playing simple cell phone games and decided I wanted to create one instead of just playing existing ones. I wanted to create a game that involved treasure and goals, that had a simple design, but from which complex strategy emerged. I had a bunch of different ideas, but decided this would be a relatively easy one to prototype and so far I'm really enjoying playing it. I also wanted to try out Swift, which I've built this entirely in (and I want to mention how much I like this language). I created this game on a plane, typed the name Bank into XCode, and I'm not sure how I typed the 23, but I think it might have been my elbow. Anyway I like it, so here's Bank 23.\n\n"
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
    if indexPath.section == 1 {
      return 110
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
      _currentRow = indexPath.row
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
