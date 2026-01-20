import UIKit
import SwiftUI
import SnapKit

final class OnboardingViewController: UIViewController {
  
  private let store: OnboardingStore
  private var pageViewController: UIPageViewController!
  private var pages: [OnboardingPageViewController] = []
  
  private lazy var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.currentPageIndicatorTintColor = DS.Color.primary
    pageControl.pageIndicatorTintColor = DS.Color.textTertiary
    return pageControl
  }()
  
  private lazy var skipButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(NSLocalizedString("onboarding.skip", comment: ""), for: .normal)
    button.setTitleColor(DS.Color.textSecondary, for: .normal)
    button.titleLabel?.font = DS.Font.bodyMedium
    return button
  }()
  
  private lazy var nextButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(NSLocalizedString("onboarding.next", comment: ""), for: .normal)
    button.backgroundColor = DS.Color.primary
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = DS.Font.headline
    button.layer.cornerRadius = DS.Size.cornerRadiusMedium
    return button
  }()
  
  init(store: OnboardingStore) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupPages()
    setupPageViewController()
    setupConstraints()
    setupActions()
  }
  
  private func setupPages() {
    let introPage = OnboardingPageViewController(
      pageType: .intro,
      store: store
    )
    
    let goalPage = OnboardingPageViewController(
      pageType: .goal,
      store: store
    )
    
    let healthKitPage = OnboardingPageViewController(
      pageType: .healthKit,
      store: store
    )
    
    let notificationPage = OnboardingPageViewController(
      pageType: .notification,
      store: store
    )
    
    let widgetPage = OnboardingPageViewController(
      pageType: .widget,
      store: store
    )
    
    pages = [introPage, goalPage, healthKitPage, notificationPage, widgetPage]
    pageControl.numberOfPages = pages.count
  }
  
  private func setupPageViewController() {
    pageViewController = UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal
    )
    pageViewController.delegate = self
    
    if let firstPage = pages.first {
      pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
    }
    
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    pageViewController.didMove(toParent: self)
  }
  
  private func setupConstraints() {
    view.addSubview(skipButton)
    view.addSubview(pageControl)
    view.addSubview(nextButton)
    
    skipButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      $0.trailing.equalToSuperview().offset(-20)
    }
    
    pageViewController.view.snp.makeConstraints {
      $0.top.equalTo(skipButton.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(nextButton.snp.top).offset(-20)
    }
    
    nextButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(32)
      $0.bottom.equalTo(pageControl.snp.top).offset(-16)
      $0.height.equalTo(56)
    }
    
    pageControl.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
    }
  }
  
  private func setupActions() {
    skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
  }
  
  @objc private func skipTapped() {
    Task {
      await store.send(.skip)
      transitionToMainApp()
    }
  }
  
  @objc private func nextTapped() {
    let currentIndex = pageControl.currentPage
    let currentPage = pages[currentIndex]
    
    switch currentPage.pageType {
    case .healthKit:
      Task {
        await store.send(.requestHealthKitPermission)
        advanceToNextPage()
      }
    case .notification:
      Task {
        await store.send(.requestNotificationPermission)
        advanceToNextPage()
      }
    default:
      if currentIndex < pages.count - 1 {
        advanceToNextPage()
      } else {
        completeOnboarding()
      }
    }
  }
  
  private func advanceToNextPage() {
    let currentIndex = pageControl.currentPage
    guard currentIndex < pages.count - 1 else {
      completeOnboarding()
      return
    }
    let nextPage = pages[currentIndex + 1]
    pageViewController.setViewControllers([nextPage], direction: .forward, animated: true)
    pageControl.currentPage = currentIndex + 1
    store.currentPage = currentIndex + 1
    updateNextButtonTitle()
  }
  
  private func updateNextButtonTitle() {
    let isLastPage = pageControl.currentPage == pages.count - 1
    let title = isLastPage
      ? NSLocalizedString("onboarding.start", comment: "")
      : NSLocalizedString("onboarding.next", comment: "")
    nextButton.setTitle(title, for: .normal)
  }
  
  private func completeOnboarding() {
    Task {
      await store.send(.completeOnboarding)
      transitionToMainApp()
    }
  }
  
  private func transitionToMainApp() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first else { return }

    let mainTabView = MainTabView(serviceProvider: store.provider)
    let hostingController = UIHostingController(rootView: mainTabView)

    window.rootViewController = hostingController
    window.makeKeyAndVisible()
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
  }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed,
       let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
       let index = pages.firstIndex(of: currentVC) else { return }
    pageControl.currentPage = index
    store.currentPage = index
    updateNextButtonTitle()
  }
}
