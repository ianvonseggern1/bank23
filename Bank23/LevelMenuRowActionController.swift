//
//  LevelMenuRowActionController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 1/6/18.
//  Copyright © 2018 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

protocol LevelMenuRowActionControllerDelegate: NSObjectProtocol {
  func openInGameEditor(level: GameModel)
  func deleteLevel(_ level: GameModel)
}

public final class LevelMenuRowActionController {
  weak var delegate: LevelMenuRowActionControllerDelegate?
  
  let _levelActionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
  let _level: GameModel
  
  init(level: GameModel) {
    _level = level
    
    _levelActionSheet.addAction(UIAlertAction(title: "Open in Editor",
                                              style: .default,
                                              handler: { (action) in
      self.delegate!.openInGameEditor(level: level)
    }))
    if (ADMIN_MODE) {
      _levelActionSheet.addAction(UIAlertAction(title: "Save to Database",
                                                style: .default,
                                                handler: { (action) in
                                                  self.saveLocalLevelToDatabase()}))
    }
    if level._levelType == LevelType.UserCreated {
      _levelActionSheet.addAction(UIAlertAction(title: "Delete",
                                                style: .destructive,
                                                handler: { (action) in
        self.delegate!.deleteLevel(level)
      }))
    }
    _levelActionSheet.addAction(UIAlertAction(title: "Cancel",
                                              style: .cancel,
                                              handler: nil))
  }
  
  func saveLocalLevelToDatabase() {
    do {
      try LevelController.writeLocalLevelToMainGameDatabase(level: _level)
    } catch {
    }
  }
}
