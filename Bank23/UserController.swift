//
//  UserController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 4/7/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore

final class UserController: LoginButtonDelegate {
  static func getUserId() -> String {
    let userDefaults = UserDefaults.standard
  
    var uuid = userDefaults.object(forKey: "Bank23UserUniqueIdentifier")
    if uuid == nil {
      uuid = UUID().uuidString
      userDefaults.set(uuid, forKey: "Bank23UserUniqueIdentifier")
      userDefaults.synchronize()
    }
    
    return uuid as! String
  }
  
  static func setUsername(_ username: String) {
    UserDefaults.standard.set(username, forKey: "Bank23Username")
    UserDefaults.standard.synchronize()
  }
  
  static func getUsername() -> String? {
    return UserDefaults.standard.object(forKey: "Bank23Username") as? String
  }
  
  static func setCurrentLevel(level: GameModel) {
    UserDefaults.standard.set(String(level.hash()), forKey: "Bank23CurrentLevel")
    UserDefaults.standard.synchronize()
  }
  
  static func getCurrentLevelHash() -> String? {
    return UserDefaults.standard.object(forKey: "Bank23CurrentLevel") as? String
  }
  
  static func setDefaultTimerMode(on: Bool) {
    UserDefaults.standard.set(on, forKey: "Bank23TimerDefaultMode")
    UserDefaults.standard.synchronize()
  }
  
  static func getDefaultTimerModeOn() -> Bool {
    return UserDefaults.standard.bool(forKey: "Bank23TimerDefaultMode")
  }
  
  // Cache all the fetched boards
  static func setCachedServerBoards(boards: [GameModel]) {
    let boardStrings = boards.map({ (game: GameModel) -> String in
      return game.toString()
    })
    UserDefaults.standard.set(boardStrings, forKey: "Bank23CachedServerBoards")
  }
  
  static func getCachedServerBoards() -> [GameModel] {
    let boardStrings = UserDefaults.standard.array(forKey: "Bank23CachedServerBoards")
    if boardStrings != nil && boardStrings!.count > 0 {
      return boardStrings!.map({ (boardString: Any) -> GameModel in
        return try! GameModel.fromString(boardString as! String)
      })
    } else {
      return []
    }
  }
  
  // LoginButtonDelegate
  
  public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
    switch result {
    case .success(let grantedPermissions, let declinedPermissions, let token):
      // TODO something with logged in user
      break
    case .cancelled:
      break
    case .failed(_):
      break
    }
  }
  
  public func loginButtonDidLogOut(_ loginButton: LoginButton) {
    
  }
}
