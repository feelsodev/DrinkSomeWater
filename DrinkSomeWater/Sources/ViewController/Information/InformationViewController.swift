//
//  InformationViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/13.
//

import UIKit
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import WaveAnimationView

final class InformationViewController: BaseViewController, View {
  
  
  // MARK: - Property
  
  let dataSource = RxTableViewSectionedReloadDataSource<InfoSection>(
    configureCell: { _, tableView, indexPath, reactor in
      let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellID, for: indexPath) as! InfoCell
      cell.reactor = reactor
      return cell
    })
  
  
  // MARK: - UI
  
  private let infoLabel = UILabel().then {
    $0.text = "Set".localized
    $0.textColor = #colorLiteral(red: 0.1739570114, green: 0.1739570114, blue: 0.1739570114, alpha: 1)
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
  }
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    $0.isUserInteractionEnabled = false
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .red
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = .zero
    $0.layer.shadowRadius = 10
    $0.layer.shadowOpacity = 0.5
  }
  
  private let tableView = IntrinsicTableView().then {
    $0.register(InfoCell.self, forCellReuseIdentifier: InfoCell.cellID)
    $0.isScrollEnabled = false
    $0.layer.cornerRadius = 20
    $0.layer.masksToBounds = true
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 0.5
    $0.separatorColor = .clear
    $0.rowHeight = 60
  }
  
  private let backButton = UIButton().then {
    $0.tintColor = .black
    $0.setImage(UIImage(systemName: "arrow.left")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    $0.layer.shadowOpacity = 1.0
    $0.layer.shadowRadius = 0.0
    $0.layer.masksToBounds = false
    $0.layer.cornerRadius = 4.0
  }
  
  
  // MARK: - Initialize
  
  init(reactor: InformationViewReactor) {
    super.init()
//    self.view.backgroundColor = .white
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Bind
  
  func bind(reactor: InformationViewReactor) {
    
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidload }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.backButton.rx.tap
      .map { Reactor.Action.cancel }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.itemSelected
      .map { Reactor.Action.itemSelect($0)}
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.sections }
      .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.shouldDismissed }
      .distinctUntilChanged()
      .subscribe { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    // View
    self.tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        switch indexPath.row {
        case 0:
          if let bundleIdentifier = Bundle.main.bundleIdentifier,
             let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            if UIApplication.shared.canOpenURL(appSettings) {
              UIApplication.shared.open(appSettings)
            }
          }
        case 1:
          let url = "itms-apps://itunes.apple.com/app/id1563673158"
          if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
              UIApplication.shared.openURL(url)
            }
          }
        case 4:
          let vc = LicensesViewController()
          self.navigationController?.pushViewController(vc, animated: true)
        default:
          break
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubviews([
      self.infoLabel, self.backButton, self.backgroundView, self.containerView, self.tableView
    ])
    self.view.bringSubviewsToFront([
      self.infoLabel, self.backButton, self.tableView
    ])
    
    self.backgroundView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(self.viewHeight / 4)
    }
    self.backButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(50)
    }
    self.infoLabel.snp.makeConstraints {
      $0.bottom.equalTo(self.tableView.snp.top).offset(-20)
      $0.centerX.equalToSuperview()
    }
    self.tableView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(self.viewHeight / 4 - 40)
      $0.leading.equalToSuperview().offset(15)
      $0.trailing.equalToSuperview().offset(-15)
    }
    self.containerView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(self.viewHeight / 4 - 40)
      $0.leading.equalToSuperview().offset(32)
      $0.trailing.equalToSuperview().offset(-32)
      $0.bottom.equalTo(self.tableView.snp.bottom)
    }
  } 
}
