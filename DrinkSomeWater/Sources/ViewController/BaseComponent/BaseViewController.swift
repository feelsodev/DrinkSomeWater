import UIKit
import SnapKit
import Then

class BaseViewController: UIViewController {
    
    var observation: ObservationToken?
    var viewWidth: CGFloat { view.bounds.width }
    var viewHeight: CGFloat { view.bounds.height }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        observation?.cancel()
    }
    
    func setupConstraints() {}
    
    func render() {}
}
