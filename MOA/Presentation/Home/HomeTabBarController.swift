//
//  HomeTabBarController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit

final class HomeTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var isInit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
        setupViewControllers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO 앱 로그인 시에만 노출 (로그인 화면에서 UserDefault true, 여기서 false)
        if isInit {
            Toast.shared.show(message: LOGIN_SUCCESS_TOAST_TITLE)
            isInit = false
            
            let calender = Calendar.current
            let now = Date()
            let fiveSecondsLater = calender.date(byAdding: .second, value: 10, to: now)!
            
            NotificationManager.shared.requestAuhthorization()
        }
    }
    
    private func setupAppearance() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        delegate = self
    }
    
    private func setupViewControllers() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.grey60], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.grey90], for: .normal)
        
        let gifticonViewController = GifticonViewController()
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
        
        setupTopBarWithLargeTitle(title: GIFTICON_MENU_TITLE)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController is GifticonViewController {
            setupTopBarWithLargeTitle(title: GIFTICON_MENU_TITLE)
        }
        
        if viewController is MapViewController {
            setupTopBarWithLargeTitle(title: MAP_MENU_TITLE)
        }
        
        if viewController is MypageViewController {
            setupTopBarWithNotification()
        }
        
        return true
    }
    
    func requestNotificationPermission() {
        MOALogger.logd()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: authOptions) { isGranted, error in
            if let error = error {
                MOALogger.loge(error.localizedDescription)
                return
            }
            
            MOALogger.logd("\(isGranted)")
        }
        
        let content = UNMutableNotificationContent()
        content.title = "테스트"
        content.body = "테스트입니다."
        
        let calendar = Calendar.current

        // 현재 시간을 기준으로 5초를 추가한 Date 생성
        let now = Date()
        let fiveSecondsLater = calendar.date(byAdding: .second, value: 10, to: now)!

        // 5초 후의 Date를 DateComponents로 변환
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fiveSecondsLater)

        print("5초 뒤: \(components)")


        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: { error in
            MOALogger.logd("request1")
            if let error = error {
                MOALogger.loge(error.localizedDescription)
            }
        })
        
        let content2 = UNMutableNotificationContent()
        content2.title = "테스트2"
        content2.body = "테스트2입니다."
        
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request2 = UNNotificationRequest(identifier: uuid, content: content2, trigger: trigger2)
        
        notificationCenter.add(request2, withCompletionHandler: { error in
            MOALogger.logd("request2")
            if let error = error {
                MOALogger.loge(error.localizedDescription)
            }
        })
        
    }
}
