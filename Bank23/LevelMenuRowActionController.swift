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
  func presentEditSortKeyAlert(_ alert: UIAlertController)
  func sortKeyUpdated()
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
      _levelActionSheet.addAction(UIAlertAction(
        title: "Edit sort key value: \(level._sortKey)",
        style: .default,
        handler: { (action) in
          self.editSortKeyFor(level: level)
      }))
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
  
  func editSortKeyFor(level: GameModel) {
    let sortKeyEditAlert = UIAlertController(
      title: "New Sort Key",
      message: "Edit sort key for \(level._levelName)",
      preferredStyle: .alert)
    sortKeyEditAlert.addTextField { (textField) in
      textField.placeholder = level._sortKey
      textField.textAlignment = .center
    }
    sortKeyEditAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
      let textField = sortKeyEditAlert.textFields![0] as UITextField
      if textField.text != nil && textField.text! != "" {
        // We assume the network call succeeds and update locally, since this is just an
        // admin feature anyway
        LevelController.editLevelSortKey(level: level, newSortKey: textField.text!)
        level._sortKey = textField.text!
        self.delegate!.sortKeyUpdated()
      }
    }))
    sortKeyEditAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.delegate!.presentEditSortKeyAlert(sortKeyEditAlert)
  }
  
  func saveLocalLevelToDatabase() {
    do {
      try LevelController.writeLocalLevelToMainGameDatabase(level: _level)
    } catch {
    }
  }
}
