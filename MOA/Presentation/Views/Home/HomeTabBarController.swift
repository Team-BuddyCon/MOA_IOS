//
//  HomeTabBarController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit

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
    
    init(gifticonDelegate: GifticonViewControllerDelegate? = nil) {
        self.gifticonDelegate = gifticonDelegate
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
        
        if UserPreferences.isShowLoginPopup() {
            Toast.shared.show(message: LOGIN_SUCCESS_TOAST_TITLE)
            UserPreferences.setShowLogin(isShow: false)
        }
        
        NotificationManager.shared.requestAuhthorization()
        UserPreferences.hideCoachMark()
    }
    
    private func setupAppearance() {
        setupTapBar()
        setupNavigationBar()
        delegate = self
        
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
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().isTranslucent = false
    }
    
    private func setupViewControllers() {
        let gifticonViewController = GifticonViewController()
        gifticonViewController.delegate = gifticonDelegate
        
        let mapViewController = MapViewController()
        let mypageViewController = MypageViewController()
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
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.grey90], for: .normal)
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
