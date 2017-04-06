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
  
  var showCount = true
  
  init(frame: CGRect, model: Piece, pieceColor: UIColor, row: Int, column: Int) {
    _row = row
    _column = column
    _model = model
    _countLabel = UILabel()
    _icon = UIImageView()
    
    super.init(frame:frame)
    
    //_countLabel.textColor = UIColor.white //_countLabel.textColor = pieceColor
    self.setPiece(model: model)
    self.addSubview(_icon)
    self.addSubview(_countLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    var topPadding:CGFloat
    var bottomPadding:CGFloat
    var horizontalPadding:CGFloat
    
    // At the moment padding is the same for all boards regardless
    // of dimensions, so 5 x 5 has preportionally less padding than 7 x 7
    // but it works pretty well because the count label font is a constant size
    switch _model {
    case .bank(_):
      topPadding = 8.0
      bottomPadding = 8.0
      horizontalPadding = 8.0
      break
    case .coins(_):
      topPadding = 9.0
      bottomPadding = 9.0
      horizontalPadding = 9.0
      break
    case .water(_):
      topPadding = 18.0
      bottomPadding = 5.0
      horizontalPadding = 5.0
      break
    case .sand(_):
      topPadding = 9.0
      bottomPadding = 9.0
      horizontalPadding = 9.0
      break
    case .mountain(_):
      topPadding = 0.0
      bottomPadding = 0.0
      horizontalPadding = 0.0
      break
    default:
      topPadding = 8.0
      bottomPadding = 8.0
      horizontalPadding = 8.0
      break
    }
    
    // hack out the padding for the level menu previews
    if self.bounds.width < 21.0 {
      topPadding = 1.0
      bottomPadding = 1.0
      horizontalPadding = 1.0
    }
    
    _icon.frame = CGRect(x: horizontalPadding,
                         y: topPadding,
                         width:self.bounds.width - horizontalPadding * 2,
                         height:self.bounds.height - topPadding - bottomPadding)
    
    _countLabel.isHidden = !showCount
    //_countLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
    _countLabel.sizeToFit()
    _countLabel.frame = CGRect(x: self.bounds.width - _countLabel.frame.width - 3,
                          y: 1,
                          width:_countLabel.frame.width,
                          height:_countLabel.frame.height)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: SINGLE_SQUARE_SIZE, height: SINGLE_SQUARE_SIZE)
  }
  
  func setPiece(model: Piece) {
    _model = model
    
    let attribs = [
      NSForegroundColorAttributeName: UIColor(red:0.29, green:0.29, blue:0.29, alpha:1.0),
      NSStrokeColorAttributeName:  UIColor(red:0.29, green:0.29, blue:0.29, alpha:1.0),
      NSStrokeWidthAttributeName: -0.0,
      NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12.0)
    ] as [String : Any]
    
    var iconImage: UIImage?
    switch model {
    case .bank(let x):
      iconImage = UIImage(named: "Piggy Bank 01.png")!
      _countLabel.attributedText = NSAttributedString(string: "\(x)", attributes: attribs)
      break
    case .coins(let x):
      iconImage = UIImage(named: "Coin Icon 01.png")
      _countLabel.attributedText = NSAttributedString(string: "\(x)", attributes: attribs)
      break
    case .water(let x):
      iconImage = UIImage(named: "Water.png")
      _countLabel.attributedText = NSAttributedString(string: "\(x)", attributes: attribs)
      break
    case .sand(let x):
      iconImage = UIImage(named: "Sandcastle 02.png")
      _countLabel.attributedText = NSAttributedString(string: "\(x)", attributes: attribs)
      break
    case .mountain(_):
      iconImage = UIImage(named: "Mountains 01.png")
      _countLabel.text = ""
      break
    default:
      break
    }
    
    _icon.image = iconImage
  }
}
