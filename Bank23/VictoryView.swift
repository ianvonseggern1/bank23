//
//  VictoryView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 4/21/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

class VictoryView: UIView {
  let _victoryLabel = UILabel()
  let _nextLevelLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    self.backgroundColor = UIColor.clear
    
    _victoryLabel.text = "YOU WON!"
    _victoryLabel.font = UIFont.systemFont(ofSize: 48, weight: UIFont.Weight(rawValue: 1.0))
    self.addSubview(_victoryLabel)
    
    _nextLevelLabel.text = "Next Level >"
    _nextLevelLabel.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight(rawValue: 1.0))
    _nextLevelLabel.textColor = UIColor.darkGray
    self.addSubview(_nextLevelLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    _victoryLabel.sizeToFit()
    _nextLevelLabel.sizeToFit()
    return CGSize(width: max(_victoryLabel.frame.width, _nextLevelLabel.frame.width),
                  height: _victoryLabel.frame.height + 4 + _nextLevelLabel.frame.height)
  }

  override func layoutSubviews() {
    _victoryLabel.sizeToFit()
    _victoryLabel.frame = CGRect(x: (self.bounds.width - _victoryLabel.frame.width) / 2.0,
                                 y: 0,
                                 width: _victoryLabel.frame.width,
                                 height: _victoryLabel.frame.height)
    
    _nextLevelLabel.sizeToFit()
    _nextLevelLabel.frame = CGRect(x: (self.bounds.width - _nextLevelLabel.frame.width) / 2.0,
                                   y: _victoryLabel.frame.maxY + 4,
                                   width: _nextLevelLabel.frame.width,
                                   height: _nextLevelLabel.frame.height)
  }
}
