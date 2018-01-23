//
//  TimerView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 1/7/18.
//  Copyright © 2018 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

final class TimerView: UIView {
  let titleLabel = UILabel(frame: CGRect.zero)
  let timeLabel = UILabel(frame: CGRect.zero)

  // TODO add arrow to indicate clickableness
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    titleLabel.text = "Time"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    titleLabel.textColor = PieceView.labelColor()
    self.addSubview(titleLabel)
    self.addSubview(timeLabel)
    
    self.backgroundColor = BoardView.backgroundColor()
    self.layer.cornerRadius = 4
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    titleLabel.sizeToFit()
    timeLabel.sizeToFit()
    let timeLabelSize = timeLabel.isHidden ? CGSize.zero : timeLabel.frame.size
    return CGSize(width: 8 + max(titleLabel.frame.width, timeLabelSize.width),
                  height: 8 + titleLabel.frame.height + timeLabelSize.height)
  }
  
  override func layoutSubviews() {
    titleLabel.sizeToFit()
    timeLabel.sizeToFit()
    titleLabel.frame = CGRect(x: 4,
                              y: 4,
                              width: titleLabel.frame.width,
                              height: titleLabel.frame.height)
    timeLabel.frame = CGRect(x: 4,
                             y: titleLabel.frame.maxY,
                             width: timeLabel.frame.width,
                             height: timeLabel.frame.height)
  }
  
  func setTime(time: Int) {
    timeLabel.text = secondsToTimeString(time: time)
  }
  
  func toggleShowTime() {
    timeLabel.isHidden = !timeLabel.isHidden
  }
}
