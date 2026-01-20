import UIKit
import SnapKit
import Analytics

class BaseViewController: UIViewController {
  
  var observation: ObservationToken?
  var viewWidth: CGFloat { view.bounds.width }
  var viewHeight: CGFloat { view.bounds.height }
  
  var analyticsScreenName: String {
    String(describing: type(of: self)).replacingOccurrences(of: "ViewController", with: "").lowercased() + "_screen"
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupConstraints()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Analytics.shared.logScreenView(analyticsScreenName)
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
