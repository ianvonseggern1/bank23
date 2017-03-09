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

  var _levelNames = [String]()
  var _initialBoards = [[[Piece]]]() // board[column][row]
  var _initialPieces = [[Piece]]()

  var _tableView : UITableView?
  var _currentRow = 0
  
  public override init () {
    // Level 1
    _levelNames.append("The Narrows")

    var initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][3] = Piece.bank(10)
    initialBoard[1][2] = Piece.water(2)
    initialBoard[3][2] = Piece.water(2)
    initialBoard[1][3] = Piece.water(5)
    initialBoard[3][3] = Piece.water(5)
    initialBoard[1][4] = Piece.water(3)
    initialBoard[3][4] = Piece.water(3)
    _initialBoards.append(initialBoard)

    var initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 2
    _levelNames.append("The Island")
    
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][2] = Piece.bank(10)
    initialBoard[1][2] = Piece.water(5)
    initialBoard[3][2] = Piece.water(5)
    initialBoard[2][3] = Piece.water(5)
    initialBoard[2][1] = Piece.water(5)
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 3
    _levelNames.append("Top Side")
    
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[2][4] = Piece.bank(10)
    initialBoard[1][4] = Piece.water(8)
    initialBoard[3][4] = Piece.water(8)
    initialBoard[2][3] = Piece.water(4)
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 4
    _levelNames.append("Corner Case")
    
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[4][4] = Piece.bank(10)
    initialBoard[4][3] = Piece.water(10)
    initialBoard[3][4] = Piece.water(10)
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 5
    _levelNames.append("The Narrows Part II")
    
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
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 6
    _levelNames.append("Worlds Apart")
    
    initialBoard = Array(repeating:Array(repeating:Piece.empty, count:5), count:5)
    initialBoard[0][2] = Piece.bank(5)
    initialBoard[4][2] = Piece.bank(5)
    initialBoard[0][1] = Piece.water(3)
    initialBoard[0][3] = Piece.water(3)
    initialBoard[1][2] = Piece.water(4)
    initialBoard[4][1] = Piece.water(3)
    initialBoard[4][3] = Piece.water(3)
    initialBoard[3][2] = Piece.water(4)
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 7
    _levelNames.append("Split Brain")
    
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
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
    
    // Level 8
    _levelNames.append("007")
    
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
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:16))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:32))
    _initialPieces.append(initialPieces)
    
    // Level 9
    _levelNames.append("Grand Canyon")
    
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
    _initialBoards.append(initialBoard)
    
    initialPieces = [Piece]()
    initialPieces.append(contentsOf: Array(repeating:Piece.coins(1), count:10))
    initialPieces.append(contentsOf: Array(repeating:Piece.sand(1), count:20))
    _initialPieces.append(initialPieces)
  }
  
  public func configureWith(tableView: UITableView) {
    tableView.dataSource = self
    tableView.delegate = self
    _tableView = tableView
  }
  
  public func currentName() -> String {
    return _levelNames[_currentRow]
  }
  
  public func initialBoard() -> [[Piece]] {
    return _initialBoards[_currentRow]
  }
  
  public func initialPieces() -> [Piece] {
    return _initialPieces[_currentRow]
  }
  
  public func add(board: [[Piece]], initialPieces: [Piece], withName: String) {
    _initialBoards.append(board)
    _initialPieces.append(initialPieces)
    _levelNames.append(withName)
    DispatchQueue.main.async(execute: { self._tableView!.reloadData() })
  }
  
  // UITableViewDataSource
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return _levelNames.count
    }
    return 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let label = UILabel()
    label.text = _levelNames[indexPath.row]
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
