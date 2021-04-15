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
  
  let backgroundView = UIView().then {
    $0.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    $0.isUserInteractionEnabled = false
  }
  
  let containerView = UIView().then {
    $0.backgroundColor = .red
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = .zero
    $0.layer.shadowRadius = 10
    $0.layer.shadowOpacity = 0.5
  }
  
  let tableView = IntrinsicTableView().then {
    $0.register(InfoCell.self, forCellReuseIdentifier: InfoCell.cellID)
    $0.layer.cornerRadius = 20
    $0.layer.masksToBounds = true
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 0.5
    $0.separatorColor = .clear
    $0.rowHeight = 60
  }
  
  let backButton = UIButton().then {
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
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
        guard let `self` = self else { return }
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction
          = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: true, completion: nil)
      }
      .disposed(by: self.disposeBag)
    
    // View
    self.tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let `self` = self else { return }
        self.tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 4 {
          let vc = LicensesViewController()
          let transition = CATransition()
          transition.duration = 0.4
          transition.type = CATransitionType.push
          transition.subtype = CATransitionSubtype.fromRight
          self.view.window?.layer.add(transition, forKey: kCATransition)
          vc.modalPresentationStyle = .fullScreen
          self.present(vc, animated: false, completion: nil)
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.backgroundColor = .white
    [self.backButton, self.backgroundView, self.containerView, self.tableView]
      .forEach { self.view.addSubview($0) }
    [self.backButton, self.tableView].forEach { self.view.bringSubviewToFront($0) }

    self.backgroundView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(UIScreen.main.bounds.height / 4)
    }
    self.backButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(50)
    }
    self.tableView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(UIScreen.main.bounds.height / 4 - 40)
      $0.leading.equalToSuperview().offset(15)
      $0.trailing.equalToSuperview().offset(-15)
    }
    self.containerView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(UIScreen.main.bounds.height / 4 - 40)
      $0.leading.equalToSuperview().offset(32)
      $0.trailing.equalToSuperview().offset(-32)
      $0.bottom.equalTo(self.tableView.snp.bottom)
    }
  } 
}
