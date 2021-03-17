//
//  DrinkViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift

class DrinkViewController: BaseViewController, View {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    init(reactor: DrinkViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: DrinkViewReactor) {
        
    }
}
