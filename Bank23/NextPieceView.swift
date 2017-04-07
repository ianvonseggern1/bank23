//
//  NextPieceView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 2/12/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import UIKit

class NextPieceView: UIView {
  var _piece: PieceView?
  let _label = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    _label.text = "Next"
    _label.font = UIFont.boldSystemFont(ofSize: 16.0)
    _label.textColor = PieceView.labelColor()
    self.addSubview(_label)
    
    self.backgroundColor = BoardView.backgroundColor()
    self.layer.cornerRadius = 4
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    _label.sizeToFit()
    return CGSize(width: max(_label.frame.width, SINGLE_SQUARE_SIZE + 2 * 4),
                  height: _label.frame.height + SINGLE_SQUARE_SIZE + 3 * 4)
  }
  
  override func layoutSubviews() {
    _label.sizeToFit()
    _label.frame = CGRect(x: self.bounds.width - 4 - _label.frame.width,
                          y: 4,
                          width:_label.frame.width,
                          height: _label.frame.height)
    
    _piece?.frame = CGRect(x: 4,
                           y: _label.frame.maxY + 4,
                           width: SINGLE_SQUARE_SIZE,
                           height: SINGLE_SQUARE_SIZE)
  }

  func setPieceModel(piece: Piece?) {
    _piece?.removeFromSuperview()
    _piece = PieceView(frame: CGRect.zero,
                       model: piece != nil ? piece! : Piece.empty,
                       row: -1,
                       column: -1)
    _piece?.showCount = false
    self.addSubview(_piece!)
    self.setNeedsLayout()
  }
}
