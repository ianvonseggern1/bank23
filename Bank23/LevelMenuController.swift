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
  
  var _currentRow = 0
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(_tableView)
    _tableView.frame = self.view.bounds
    _tableView.dataSource = self
    _tableView.delegate = self
    
    _editGameViewController.delegate = self
    
    // Setup Navigation Bar

    self.navigationItem.title = "Main Menu"
    
    let menuIcon = UIButton() // todo, replace with an 'X' image
    menuIcon.setImage(UIImage(named: "menu-icon25.png"), for: UIControlState.normal)
    menuIcon.bounds = CGRect(x: 0, y: 0, width: 25, height: 22)
    menuIcon.addTarget(self, action: #selector(didTapMenu), for: UIControlEvents.touchUpInside)
    self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: menuIcon), animated: false)
  }

  public func fetchLevels() {
    addLocalLevels()
    LevelNetworker.getAllBoardsFromDatabase(boardCallback: self.add)
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
    return 3
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return _initialGameModels.count
    } else if section == 2 {
      return 1
    }
    return 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableViewCell = UITableViewCell()
    tableViewCell.selectionStyle = UITableViewCellSelectionStyle.none

    if indexPath.section == 0 {
      let usernameLabel = UILabel()
      usernameLabel.text = "Your Username: "
      usernameLabel.sizeToFit()
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
      let label = UILabel()
      label.text = _initialGameModels[indexPath.row]._levelName
      label.sizeToFit()
      label.frame = CGRect(x: 10,
                           y: 10,
                           width: label.frame.width,
                           height: label.frame.height)
      tableViewCell.addSubview(label)
      
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
      label.sizeToFit()
      label.frame = CGRect(x: 10,
                           y: 10,
                           width: label.frame.width,
                           height: label.frame.height)
      tableViewCell.addSubview(label)
    }

    return tableViewCell
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 1 {
      return 110
    }
    return 60
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
