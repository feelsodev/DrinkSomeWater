//
//  InfoCell.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class InfoCell: BaseTableViewCell, View {
  typealias Reactor = InfoCellReactor
  
  
  // MARK: - Property
  
  static let cellID = "InfoCell"
  
  
  // MARK: - Constants
  
  struct Constant {
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
  }
  
  
  // MARK: - UI
  
  let icon = UIImageView().then {
    $0.tintColor = .black
    $0.backgroundColor = .white
  }
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  
  // MARK: - Bind
  
  func bind(reactor: Reactor) {
    self.titleLabel.text = reactor.currentState.title
    self.icon.image = reactor.currentState.key.getImage()
    
    switch reactor.currentState.key {
    case .version:
      let versionLabel = UILabel(
        frame: CGRect(x: 0, y: 0, width: 40, height: 20)
      ).then {
        $0.text = Constant.version
        $0.textColor = .black
        $0.textAlignment = .right
      }
      self.accessoryView = versionLabel
    default:
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
