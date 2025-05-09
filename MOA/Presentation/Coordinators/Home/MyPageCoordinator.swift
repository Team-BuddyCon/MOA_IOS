//
//  MyPageCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/8/25.
//

import UIKit
import MessageUI

protocol MyPageCoordinatorDelegate: AnyObject {
    func navigateToLoginFromLogout()
    func navigateToLoginFromWithDraw()
    func navigateToGifticonDetail(gifticonId: String)
}

class MyPageCoordinator: NSObject, Coordinator, MypageViewControllerDelegate, WithDrawViewControllerDelegate, UnAvailableGifticonViewControllerDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    weak var delegate: MyPageCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        MOALogger.logd()
    }
    
    func start() {
        MOALogger.logd()
    }
    
    // MARK: MypageViewControllerDelegate
    func navigateToUnavailableGifticon() {
        let unavailableVC = UnAvailableGifticonViewController()
        unavailableVC.delegate = self
        self.navigationController.pushViewController(unavailableVC, animated: true)
    }
    
    func navigateToNotificationSetting() {
        let notificationVC = NotificationSettingViewController()
        self.navigationController.pushViewController(notificationVC, animated: true)
    }
    
    func navigateToMailCompose() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([MOA_INQUERY_MAIL])
        mailVC.setSubject(MOA_INQUERY_SUBJECT)
        self.navigationController.present(mailVC, animated: true)
    }
    
    func navigateToVersion() {
        let versionVC = VersionViewController()
        self.navigationController.pushViewController(versionVC, animated: true)
    }
    
    func navigateToPolicy() {
        let policyVC = PolicyWebViewController(
            policyUrl: SERVICE_TERMS_URL,
            privacyUrl: PRIVACY_INFORMATION_URL
        )
        self.navigationController.pushViewController(policyVC, animated: true)
    }
    
    func navigateToLoginFromLogout() {
        self.delegate?.navigateToLoginFromLogout()
    }
    
    func navigateToWithDraw() {
        let withDrawVC = WithDrawViewController()
        withDrawVC.delegate = self
        self.navigationController.pushViewController(withDrawVC, animated: true)
    }
    
    // MARK: WithDrawViewControllerDelegate
    func navigateToLoginFromWithDraw() {
        self.delegate?.navigateToLoginFromWithDraw()
    }
    
    func navigateBack() {
        self.navigationController.popViewController(animated: true)
    }
    
    // MARK: UnAvailableGifticonViewControllerDelegate
    func navigateToGifticonDetail(gifticonId: String) {
        self.delegate?.navigateToGifticonDetail(gifticonId: gifticonId)
    }
}

extension MyPageCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        self.navigationController.dismiss(animated: true)
    }
}
