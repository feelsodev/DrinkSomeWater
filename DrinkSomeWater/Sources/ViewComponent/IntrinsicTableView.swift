//
//  IntrinsicTableView.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import UIKit

class IntrinsicTableView: UITableView {
  var maxHeight: CGFloat = 2000
  
  override var contentSize: CGSize {
      didSet {
          invalidateIntrinsicContentSize()
      }
  }
  
  override func reloadData() {
      super.reloadData()
      self.invalidateIntrinsicContentSize()
      self.layoutIfNeeded()
  }
  
  override var intrinsicContentSize: CGSize {
      let height = min(contentSize.height, maxHeight)
      return CGSize(width: contentSize.width, height: height)
  }
}
