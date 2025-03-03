//
//  MypageViewController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseAuth
import FirebaseCore
import MessageUI

final class MypageViewController: BaseViewController {
    
    let menus = MenuType.allCases
    private let titleLabel: UILabel = {
        let label = UILabel()
        let userName = UserPreferences.getLoginUserName()
        label.setTextWithLineHeight(
            text: String(format: MYPAGE_MAIN_TITLE_FORMAT, userName),
            font: pretendard_bold,
            size: 22.0,
            lineSpacing: 30.8,
            alignment: .left
        )
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var unavailableBox: UnAvailableGifticonBox = {
        let box = UnAvailableGifticonBox()
        return box
    }()
    
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MypageMenuCell.self, forCellReuseIdentifier: MypageMenuCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    let mypageViewModel = MypageViewModel(gifticonService: GifticonService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mypageViewModel.fetchUsedGifticons()
    }
}

private extension MypageViewController {
    func setupLayout() {
        [titleLabel, unavailableBox, menuTableView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12.0)
            $0.horizontalEdges.equalToSuperview().inset(20.0)
        }
        
        unavailableBox.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20.0)
            $0.height.equalTo(92)
        }
        
        menuTableView.snp.makeConstraints {
            $0.top.equalTo(unavailableBox.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
    }
    
    func bind() {
        let tapGesture = UITapGestureRecognizer()
        unavailableBox.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .map({ _ in })
            .bind(to: self.rx.bindUnavailableBox)
            .disposed(by: disposeBag)
        
        mypageViewModel.gifticonRelay
            .map { String(format: UNAVAILABLE_GIFTICON_COUNT_FORMAT, $0.count) }
            .bind(to: self.unavailableBox.countLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: MypageViewController {
    var bindUnavailableBox: Binder<Void> {
        return Binder(base) { viewController, _ in
            MOALogger.logd()
            let unavailableVC = UnAvailableGifticonViewController()
            viewController.navigationController?.pushViewController(unavailableVC, animated: true)
        }
    }
}

extension MypageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MypageMenuCell.identifier, for: indexPath) as? MypageMenuCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.setup(menuType: menus[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MypageMenuCell {
            switch cell.menuType {
            case .Notification:
                let notificationVC = NotificationViewController()
                navigationController?.pushViewController(notificationVC, animated: true)
            case .Inquery:
                if MFMailComposeViewController.canSendMail() {
                    MOALogger.logd()
                    let mailVC = MFMailComposeViewController()
                    mailVC.mailComposeDelegate = self
                    mailVC.setToRecipients([MOA_INQUERY_MAIL])
                    mailVC.setSubject(MOA_INQUERY_SUBJECT)
                    present(mailVC, animated: true)
                } else {
                    showAlertModal(
                        title: MOA_CANT_INQUERY_TITLE,
                        subTitle: MOA_CANT_INQUERY_SUBTITLE,
                        confirmText: CONFIRM
                    )
                }
            case .Version:
                let versionVC = VersionViewController()
                navigationController?.pushViewController(versionVC, animated: true)
            case .Policy:
                let termsVC = PolicyWebViewController(
                    policyUrl: SERVICE_TERMS_URL,
                    privacyUrl: PRIVACY_INFORMATION_URL
                )
                navigationController?.pushViewController(termsVC, animated: true)
            case .OpenSourceLicense:
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            case .Logout:
                showSelectModal(
                    title: LOGOUT_ALERT_TITLE,
                    subTitle: LOGOUT_ALERT_SUBTITLE,
                    confirmText: LOGOUT_CONFIRM_BUTTON_TITLE,
                    cancelText: LOGOUT_CANCEL_BUTTON_TITLE
                ) {
                    let auth = Auth.auth()
                    do {
                        NotificationManager.shared.removeAll()
                        try auth.signOut()
                        UIApplication.shared.setRootViewController(viewController: LoginViewController(isLogout: true))
                    } catch let error as NSError {
                        MOALogger.loge("\(error.localizedDescription)")
                    }
                }
            case .SignOut:
                NotificationManager.shared.removeAll()
                let withDrawVC = WithDrawViewController()
                navigationController?.pushViewController(withDrawVC, animated: true)
            }
        }
    }
}

extension MypageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        dismiss(animated: true)
    }
}
