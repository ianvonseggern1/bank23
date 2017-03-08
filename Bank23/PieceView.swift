//
//  PieceView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/23/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit

class PieceView: UIView {
  var _model:Piece
  let _countLabel:UILabel
  let _icon:UIImageView
  let _row: Int
  let _column: Int
  
  init(frame: CGRect, model: Piece, pieceColor: UIColor, row: Int, column: Int) {
    _row = row
    _column = column
    _model = model
    _countLabel = UILabel()
    _icon = UIImageView()
    
    super.init(frame:frame)
    
    _countLabel.textColor = pieceColor
    self.setPiece(model: model)
    self.addSubview(_icon)
    self.addSubview(_countLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    var padding:CGFloat
    switch _model {
    case .bank(_):
      padding = 4.0
      break
    case .coins(_):
      padding = 8.0
      break
    case .water(_):
      padding = 8.0
      break
    case .sand(_):
      padding = 2.0
      break
    case .mountain(_):
      padding = 8.0
      break
    default:
      padding = 2.0
      break
    }
    
    _icon.frame = CGRect(x: padding,
                         y: padding,
                         width:self.bounds.width - padding * 2,
                         height:self.bounds.height - padding * 2)
    _countLabel.sizeToFit()
    _countLabel.frame = CGRect(x: self.bounds.width - _countLabel.frame.width,
                          y: 0,
                          width:_countLabel.frame.width,
                          height:_countLabel.frame.height)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: SINGLE_SQUARE_SIZE, height: SINGLE_SQUARE_SIZE)
  }
  
  func setPiece(model: Piece) {
    _model = model
    
    var iconImage: UIImage?
    switch model {
    case .bank(let x):
      iconImage = UIImage(named: "Piggy Bank 01.png")!
      _countLabel.text = "\(x)"
      break
    case .coins(let x):
      iconImage = UIImage(named: "Coin Icon 01.png")
      _countLabel.text = "\(x)"
      break
    case .water(let x):
      iconImage = UIImage(named: "Water.png")
      _countLabel.text = "\(x)"
      break
    case .sand(let x):
      iconImage = UIImage(named: "sand-pile.png")
      _countLabel.text = "\(x)"
      break
    case .mountain(let x):
      iconImage = UIImage(named: "mountain2.png")
      _countLabel.text = "\(x)"
      break
    default:
      break
    }
    
    _icon.image = iconImage
  }
}
