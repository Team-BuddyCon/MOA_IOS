//
//  HomeTabBarController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit

protocol HomeTabBarControllerDelegate: AnyObject {
    func navigateToNotification()
}

final class HomeTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private lazy var coachMarkView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var coachMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: COACH_MARK_ICON)
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCoachMark))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    weak var gifticonDelegate: GifticonViewControllerDelegate?
    weak var mapDelegate: MapViewControllerDelegate?
    weak var mypageDelegate: MypageViewControllerDelegate?
    weak var homeTabDelegate: HomeTabBarControllerDelegate?
    
    init(
        gifticonDelegate: GifticonViewControllerDelegate? = nil,
        mapDelegate: MapViewControllerDelegate? = nil,
        mypageDelegate: MypageViewControllerDelegate? = nil
    ) {
        self.gifticonDelegate = gifticonDelegate
        self.mapDelegate = mapDelegate
        self.mypageDelegate = mypageDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
        setupViewControllers()
        setupTopBarWithLargeTitleAndNotification(title: GIFTICON_MENU_TITLE)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTapBar()
        setupNavigationBar()
        
        if UserPreferences.isShowLoginPopup() {
            Toast.shared.show(message: LOGIN_SUCCESS_TOAST_TITLE)
            UserPreferences.setShowLogin(isShow: false)
        }
        
        NotificationManager.shared.requestAuhthorization()
        UserPreferences.hideCoachMark()
    }
    
    private func setupAppearance() {
        self.delegate = self
        
        if !UserPreferences.isHideCoachMark() {
            self.view.addSubview(coachMarkView)
            self.view.addSubview(coachMarkImageView)
            coachMarkView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        
            coachMarkImageView.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(tabBar.layer.frame.height + 80)
                $0.trailing.equalToSuperview().inset(20)
            }
            
            // 최초 진입 시(코치마크) 일정 저장
            UserPreferences.setNotificationUpdateDate()
        }
    }
    
    private func setupTapBar() {
        view.backgroundColor = .white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
        tabBar.isTranslucent = false
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.grey60
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.grey90
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        
        guard let gifticonViewController = MOAContainer.shared.resolve(GifticonViewController.self) else { return }
        gifticonViewController.delegate = gifticonDelegate
        
        guard let mapViewController = MOAContainer.shared.resolve(MapViewController.self) else { return }
        mapViewController.delegate = mapDelegate
        
        guard let mypageViewController = MOAContainer.shared.resolve(MypageViewController.self) else { return }
        mypageViewController.delegate = mypageDelegate
        
        setViewControllers([gifticonViewController, mapViewController, mypageViewController], animated: true)
        
        if let items = tabBar.items {
            items[0].image = UIImage(named: GIFTICON_MENU)?.withRenderingMode(.alwaysOriginal)
            items[0].selectedImage = UIImage(named: GIFTICON_SELECTED_MENU)?.withRenderingMode(.alwaysOriginal)
            items[0].title = GIFTICON_MENU_TITLE
            
            items[1].image = UIImage(named: MAP_MENU)?.withRenderingMode(.alwaysOriginal)
            items[1].selectedImage = UIImage(named: MAP_SELECTED_MENU)?.withRenderingMode(.alwaysOriginal)
            items[1].title = MAP_MENU_TITLE
            
            items[2].image = UIImage(named: MYPAGE_MENU)?.withRenderingMode(.alwaysOriginal)
            items[2].selectedImage = UIImage(named: MYPAGE_SELECTED_MENU)?.withRenderingMode(.alwaysOriginal)
            items[2].title = MYPAGE_MENU_TITLE
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is GifticonViewController {
            setupTopBarWithLargeTitleAndNotification(title: GIFTICON_MENU_TITLE)
        }
        
        if viewController is MapViewController {
            setupTopBarWithLargeTitle(title: MAP_MENU_TITLE)
        }
        
        if viewController is MypageViewController {
            setupTopBarWithNotification()
        }
        
        return true
    }

    @objc func tapCoachMark() {
        MOALogger.logd()
        coachMarkView.isHidden = true
        coachMarkImageView.isHidden = true
    }
}

extension HomeTabBarController {
    func setupTopBarWithNotification() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = makeNotificationButton()
    }
    
    func setupTopBarWithLargeTitleAndNotification(title: String) {
        navigationItem.leftBarButtonItem = makeLeftLargeTitle(title: title)
        navigationItem.rightBarButtonItem = makeNotificationButton()
    }
    
    @objc private func makeNotificationButton() -> UIBarButtonItem {
        let button = UIButton()
        button.setImage(UIImage(named: NOTIFICATION_ICON), for: .normal)
        button.setImage(UIImage(named: NOTIFICATION_ICON), for: .highlighted)
        button.tintColor = .grey90
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(tapNotification), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    @objc private func tapNotification() {
        self.homeTabDelegate?.navigateToNotification()
    }
}
