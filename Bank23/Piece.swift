//
//  Piece.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/16/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation

enum PieceModelError: Error {
  case couldNotCreatePieceFromString
  case canNotIncrementWithPieceOfDifferentType
}

public enum Piece {
  case empty
  case bank(Int)
  case coins(Int)
  case water(Int)
  case sand(Int)
  case mountain(Int)
  
  public static func initFromName(_ name: String) throws -> Piece {
    let indexOfCount = name.index(name.startIndex, offsetBy: 1)
    let count = Int(name[indexOfCount...])
    let pieceTypeString = String(name[..<indexOfCount])
    if pieceTypeString != "e" && count == nil {
      throw PieceModelError.couldNotCreatePieceFromString
    }
    switch pieceTypeString {
    case "e":
      return Piece.empty
    case "b":
      return Piece.bank(count!)
    case "c":
      return Piece.coins(count!)
    case "w":
      return Piece.water(count!)
    case "s":
      return Piece.sand(count!)
    case "m":
      return Piece.mountain(count!)
    default:
      throw PieceModelError.couldNotCreatePieceFromString
    }
  }
  
  public func shortName() -> String {
    switch self {
    case .empty:
      return "e"
    case .bank(let x):
      return "b".appending(String(x))
    case .coins(let x):
      return "c".appending(String(x))
    case .water(let x):
      return "w".appending(String(x))
    case .sand(let x):
      return "s".appending(String(x))
    case .mountain(let x):
      return "m".appending(String(x))
    }
  }
  
  public func typeName() -> String {
    switch self {
    case .empty:
      return "empty"
    case .bank(_):
      return "bank"
    case .coins(_):
      return "coins"
    case .water(_):
      return "water"
    case .sand(_):
      return "sand"
    case .mountain(_):
      return "mountain"
    }
  }

  public static func == (left: Piece, right: Piece) -> Bool {
    switch (left, right) {
    case (.empty, .empty):
      return true
    case (.bank(let x), .bank(let y)):
      return x == y
    case (.coins(let x), .coins(let y)):
      return x == y
    case (.water(let x), .water(let y)):
      return x == y
    case (.sand(let x), .sand(let y)):
      return x == y
    case (.mountain(let x), .mountain(let y)):
      return x == y;
    default:
      return false
    }
  }
  
  public static func != (left: Piece, right: Piece) -> Bool {
    return !(left == right)
  }
  
  // Returns a piece of type left with a count that is the sum of left and right
  public static func + (left: Piece, right: Piece) -> Piece {
    return left.increment(right.value())
  }
  
  public static func - (left: Piece, right: Piece) -> Piece {
    if (left.value() == right.value()) {
      return Piece.empty
    } else if (left.value() > right.value()) {
      return left.increment(-1 * right.value())
    } else {
      return right.increment(-1 * left.value())
    }
  }
  
  func increment(_ value: Int) -> Piece {
    switch self {
    case .bank(let x):
      return Piece.bank(x + value)
    case .coins(let x):
      return Piece.coins(x + value)
    case .water(let x):
      return Piece.water(x + value)
    case .sand(let x):
      return Piece.sand(x + value)
    case .mountain(let x):
      return Piece.mountain(x + value)
    default:
      // ERROR - NOT SUPPORTED
      return Piece.empty
    }
  }
  
  func increment(_ piece: Piece) throws -> Piece {
    if !self.sameType(otherPiece: piece) {
      throw PieceModelError.canNotIncrementWithPieceOfDifferentType
    }
    return self.increment(piece.value())
  }
  
  func createPieceWithSameType(value : Int) -> Piece {
    switch self {
    case .bank(_):
      return Piece.bank(value)
    case .coins(_):
      return Piece.coins(value)
    case .water(_):
      return Piece.water(value)
    case .sand(_):
      return Piece.sand(value)
    case .mountain(_):
      return Piece.mountain(value)
    default:
      // ERROR - NOT SUPPORTED
      return Piece.empty
    }
  }
  
  func value() -> Int {
    switch self {
    case .coins(let x):
      return x
    case .sand(let x):
      return x
    case .bank(let x):
      return x
    case .water(let x):
      return x
    case .mountain(let x):
      return x
    case .empty:
      return 0
    }
  }
  
  func moves() -> Bool {
    switch self {
    case .coins(_):
      return true
    case .sand(_):
      return true
    case .bank(_):
      return false
    case .water(_):
      return false
    case .mountain(_):
      return false
    case .empty:
      return true // return true to allow movement after all pieces are used up
    }
  }
  
  func sameType(otherPiece: Piece) -> Bool {
    switch (self, otherPiece) {
    case (.empty, .empty):
      return true
    case (.bank(_), .bank(_)):
      return true
    case (.coins(_), .coins(_)):
      return true
    case (.water(_), .water(_)):
      return true
    case (.sand(_), .sand(_)):
      return true
    case (.mountain(_), .mountain(_)):
      return true
    default:
      return false
    }
  }
  
  // This Piece decrements otherPiece (money in da bank for example)
  func complementary(otherPiece: Piece) -> Bool {
    switch (self, otherPiece) {
    case (.coins(_), .bank(_)):
      return true;
    case (.sand(_), .water(_)):
      return true;
    default:
      return false;
    }
  }
  
  // as in the otherPiece just eats this one up without decrementing it (gold sinking in the ocean!)
  func eats(otherPiece: Piece) -> Bool {
    switch (self, otherPiece) {
    case(.coins(_), .water(_)):
      return true
    default:
      return false;
    }
  }

  // Called to see what happens if you try to slide this piece into an existing piece
  // Returns nil if they can't be joined, otherwise returns the joined piece
  func joinInto(existing: Piece) -> Piece? {
    if !self.moves() {
      return nil
    }
    if existing == Piece.empty {
      return self
    }
    if sameType(otherPiece: existing) {
      return existing + self
    }
    if complementary(otherPiece: existing) {
      return existing - self
    }
    if eats(otherPiece: existing) {
      return existing
    }
    return nil
  }
}
