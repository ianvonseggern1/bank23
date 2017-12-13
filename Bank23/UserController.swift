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
    let userDefaults = UserDefaults.standard
    userDefaults.set(username, forKey: "Bank23Username")
    userDefaults.synchronize()
  }
  
  static func getUsername() -> String? {
    return UserDefaults.standard.object(forKey: "Bank23Username") as? String
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
