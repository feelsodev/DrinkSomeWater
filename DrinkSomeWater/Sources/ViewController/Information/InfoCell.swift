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
    
    switch reactor.currentState.key {
    case .alarm:
      let switchView = UISwitch().then {
        $0.isOn = true
        $0.isUserInteractionEnabled = true
      }
      self.accessoryView = switchView
    case .review:
      self.accessoryType = .disclosureIndicator
    case .version:
      let versionLabel = UILabel(
        frame: CGRect(x: 0, y: 0, width: 42, height: 21)
      ).then {
        $0.text = "1.2.1"
        $0.textColor = .black
      }
      self.accessoryView = versionLabel
    case .question:
      self.accessoryType = .disclosureIndicator
    case .license:
      self.accessoryType = .disclosureIndicator
    }
  }
  
  override func initialize() {
    self.backgroundColor = .white
  }
  
  override func setupConstraints() {
    [self.icon, self.titleLabel].forEach { self.contentView.addSubview($0) }
    self.icon.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(10)
      $0.centerY.equalToSuperview()
      $0.height.width.equalTo(30)
    }
    self.titleLabel.snp.makeConstraints {
      $0.leading.equalTo(self.icon.snp.trailing).offset(10)
      $0.trailing.equalToSuperview().offset(-30)
      $0.centerY.equalToSuperview()
    }
  }
}
