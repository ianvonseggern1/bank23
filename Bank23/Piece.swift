//
//  Piece.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/16/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation

public enum Piece {
  case empty
  case bank(Int)
  case coins(Int)
  case water(Int)
  case sand(Int)

  public static func == (left: Piece, right: Piece) -> Bool {
    switch (left, right) {
    case (.empty, .empty):
      return true;
    case (.bank(let x), .bank(let y)):
      return x == y;
    case (.coins(let x), .coins(let y)):
      return x == y;
    case (.water(let x), .water(let y)):
      return x == y;
    case (.sand(let x), .sand(let y)):
      return x == y;
    default:
      return false;
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
    case .empty:
      return true // return true to allow movement after all pieces are used up
    }
  }
  
  func sameType(otherPiece: Piece) -> Bool {
    switch (self, otherPiece) {
    case (.empty, .empty):
      return true;
    case (.bank(_), .bank(_)):
      return true;
    case (.coins(_), .coins(_)):
      return true;
    case (.water(_), .water(_)):
      return true;
    case (.sand(_), .sand(_)):
      return true;
    default:
      return false;
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
