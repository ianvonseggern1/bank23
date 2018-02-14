//
//  LevelMenuLevelRowView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/21/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

import UIKit

class LevelMenuLevelRowView: UIView {
  let _levelName = UILabel()
  // Subtitle shows the record time and record holder name if this is a server level
  // or informs you if the level was made by you
  let _subtitle = UILabel()
  let _personalBestTime = UILabel()
  var _checkmark = UIImageView() // Shown if they have beaten the level before
  let _boardView = BoardView(frame: CGRect.zero)
  let _currentLevelView = UIView()
  
  init(gameModel: GameModel, levelBeatenTime: Int?, bestTimeInfo: BestTime?) {
    super.init(frame: CGRect.zero)
    
    _levelName.text = gameModel._levelName
    _levelName.font = UIFont.boldSystemFont(ofSize: 16.0)
    _levelName.sizeToFit()
    self.addSubview(_levelName)
    
    if bestTimeInfo != nil && bestTimeInfo!.time != 0 {
      let recordHolderName: String
      if bestTimeInfo!.userID == UserController.getUserId() {
        recordHolderName = "You!"
      } else if bestTimeInfo!.username != nil && bestTimeInfo!.username != "Unknown" {
        recordHolderName = bestTimeInfo!.username!
      } else {
        recordHolderName = ""
      }
      _subtitle.text = "Record: \(secondsToTimeString(time: bestTimeInfo!.time)) \(recordHolderName)"
    } else if gameModel._levelType == LevelType.UserCreated {
      _subtitle.text = "Created by You!"
    }
    _subtitle.font = UIFont.systemFont(ofSize: 12.0)
    _subtitle.textColor = UIColor.gray
    _subtitle.sizeToFit()
    self.addSubview(_subtitle)
    
    _checkmark.image = UIImage(named: "Checkmark (1).png")
    _checkmark.isHidden = levelBeatenTime == nil
    self.addSubview(_checkmark)
    
    _currentLevelView.backgroundColor = BoardView.lineColor()
    _currentLevelView.isHidden = true
    self.addSubview(_currentLevelView)
      
    // For levels beaten before we stored the time we set time to INT_MAX
    // Skip showing the time in that case
    if levelBeatenTime != nil && levelBeatenTime != Int(INT_MAX) {
      _personalBestTime.text = secondsToTimeString(time: levelBeatenTime!)
    }
    _personalBestTime.font = UIFont.systemFont(ofSize: 12.0)
    _personalBestTime.sizeToFit()
    self.addSubview(_personalBestTime)
    
    _boardView.showCountLabels = false
    _boardView.updateModel(board: gameModel._board._board)
    self.addSubview(_boardView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    _levelName.frame = CGRect(x: 10,
                              y: 10,
                              width: min(_levelName.frame.width, self.frame.width - 110),
                              height: _levelName.frame.height)
    
    _subtitle.frame = CGRect(x: 10,
                             y: _levelName.frame.maxY + 5,
                             width: min(_subtitle.frame.width, self.frame.width - 110),
                             height: _subtitle.frame.height)
    
    _boardView.frame =  CGRect(x: self.frame.width - 100,
                               y: 10,
                               width: 90,
                               height: 90)
    
    _checkmark.frame = CGRect(x: 10,
                               y: 90 - 20,
                               width: 20,
                               height: 20)
    
    _personalBestTime.frame = CGRect(x: _checkmark.frame.maxX + 10,
                              y: 90 - _personalBestTime.frame.height,
                              width: _personalBestTime.frame.width,
                              height: _personalBestTime.frame.height)
    
    _currentLevelView.frame = CGRect(x: 0, y: 0, width: 5, height: self.frame.height)
  }
}
