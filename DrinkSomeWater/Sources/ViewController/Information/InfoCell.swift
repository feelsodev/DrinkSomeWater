//
//  InfoCell.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import Foundation
import ReactorKit
import RxSwift

final class InfoCell: BaseTableViewCell, View {
  typealias Reactor = InfoCellReactor
  
  static let cellID = "InfoCell"
  
  let icon = UIImageView().then {
    $0.tintColor = .black
    $0.backgroundColor = .white
  }
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  func bind(reactor: Reactor) {
    self.titleLabel.text = reactor.currentState.title
    self.icon.image = reactor.currentState.key.getImage()
  }
  
  override func initialize() {
    [self.icon, self.titleLabel].forEach { self.contentView.addSubview($0) }
    self.icon.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(10)
      $0.centerY.equalToSuperview()
      $0.height.width.equalTo(40)
    }
    self.titleLabel.snp.makeConstraints {
      $0.leading.equalTo(self.icon.snp.trailing).offset(10)
      $0.centerY.equalToSuperview()
    }
  }
}
