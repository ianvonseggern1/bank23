//
//  BuiltInLevels.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/21/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

public final class BuiltInLevels {
  static func get() -> [GameModel] {
    // Helpful reminder board is indexed first by column, then row i.e. board[column][row]
    var models = [GameModel]()
    
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
    
    models.append(try! GameModel(name: "The Narrows",
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
    
    models.append(try! GameModel(name: "The Island",
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
    
    models.append(try! GameModel(name: "Top Side",
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
    
    models.append(try! GameModel(name: "Corner Case",
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
    
    models.append(try! GameModel(name: "The Narrows Part II",
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
    
    models.append(try! GameModel(name: "Worlds Apart",
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
    
    models.append(try! GameModel(name: "Split Brain",
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
    
    let level8 = try! GameModel(name: "007",
                                collapsedPieces: initialPieces,
                                initialBoard: initialBoard)
    level8._sortKey = "pm"
    models.append(level8)
    
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
    
    models.append(try! GameModel(name: "Grand Canyon",
                                             collapsedPieces: initialPieces,
                                             initialBoard: initialBoard))
    
    return models
  }
}
