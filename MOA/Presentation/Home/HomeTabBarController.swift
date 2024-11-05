//
//  HomeTabBarController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit

final class HomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
        setupViewControllers()
    }
    
    private func setupAppearance() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
    }
    
    private func setupViewControllers() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.grey60], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.grey90], for: .normal)
        
        let gifticonViewController = UINavigationController(rootViewController: GifticonViewController())
        let mapViewController = UINavigationController(rootViewController: MapViewController())
        let mypageViewController = UINavigationController(rootViewController: MypageViewController())
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
}

