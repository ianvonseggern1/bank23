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

public class LevelMenuController: NSObject, UITableViewDataSource, UITableViewDelegate {
  weak var delegate: LevelMenuControllerDelegate?

  var _initialGameModels = [GameModel]()

  var _tableView : UITableView?
  var _currentRow = 0
  
  public override init () {
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
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
                                             initialPieces: initialPieces,
                                             initialBoard: initialBoard))
  }
  
  public func configureWith(tableView: UITableView) {
    tableView.dataSource = self
    tableView.delegate = self
    _tableView = tableView
  }
  
  public func currentName() -> String {
    return _initialGameModels[_currentRow]._levelName
  }
  
  public func initialBoard() -> [[Piece]] {
    return _initialGameModels[_currentRow]._board._board
  }
  
  public func initialPieces() -> [Piece] {
    return _initialGameModels[_currentRow]._pieces
  }
  
  public func add(board: [[Piece]], initialPieces: [Piece], withName: String) {
    _initialGameModels.append(try! GameModel(name: withName,
                                             initialPieces: initialPieces,
                                             initialBoard: board))
    DispatchQueue.main.async(execute: { self._tableView!.reloadData() })
  }
  
  // UITableViewDataSource
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return _initialGameModels.count
    }
    return 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let label = UILabel()
    label.text = _initialGameModels[indexPath.row]._levelName
    label.sizeToFit()
    label.frame = CGRect(x: 10, y: 10, width: label.frame.width, height: label.frame.height)

    let tableViewCell = UITableViewCell()
    tableViewCell.addSubview(label)
    tableViewCell.sizeToFit()
    return tableViewCell
  }
  
  // UITableViewDelegate
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    _currentRow = indexPath.row
    delegate?.reset()
  }
}
