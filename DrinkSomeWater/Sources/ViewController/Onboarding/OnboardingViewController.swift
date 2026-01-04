import UIKit
import SnapKit
import Then

final class OnboardingViewController: UIViewController {
    
    private let store: OnboardingStore
    private var pageViewController: UIPageViewController!
    private var pages: [OnboardingPageViewController] = []
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = DS.Color.primary
        $0.pageIndicatorTintColor = DS.Color.textTertiary
    }
    
    private let skipButton = UIButton(type: .system).then {
        $0.setTitle(NSLocalizedString("onboarding.skip", comment: ""), for: .normal)
        $0.setTitleColor(DS.Color.textSecondary, for: .normal)
        $0.titleLabel?.font = DS.Font.bodyMedium
    }
    
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
            store: store,
            onComplete: { [weak self] in
                self?.completeOnboarding()
            }
        )
        
        pages = [introPage, goalPage, healthKitPage, notificationPage, widgetPage]
        pageControl.numberOfPages = pages.count
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = self
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
        
        skipButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(skipButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top).offset(-20)
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }
    
    @objc private func skipTapped() {
        Task {
            await store.send(.skip)
            transitionToMainApp()
        }
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
        
        let serviceProvider = ServiceProvider()
        let tabBarController = MainTabBarController(serviceProvider: serviceProvider)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentPage),
              currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentPage),
              currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = pages.firstIndex(of: currentVC) else { return }
        pageControl.currentPage = index
        store.currentPage = index
    }
}
