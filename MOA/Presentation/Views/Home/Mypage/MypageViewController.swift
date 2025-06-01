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

protocol MypageViewControllerDelegate: AnyObject {
    func navigateToUnavailableGifticon()
    func navigateToNotificationSetting()
    func navigateToMailCompose()
    func navigateToVersion()
    func navigateToPolicy()
    func navigateToLoginFromLogout()
    func navigateToWithDraw()
}

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
    
    let viewWillAppear = PublishRelay<Void>()
    let tapNotification = PublishRelay<Void>()
    let tapInquery = PublishRelay<Void>()
    let tapVersion = PublishRelay<Void>()
    let tapPolicy = PublishRelay<Void>()
    let tapOpenSourceLicense = PublishRelay<Void>()
    let tapLogout = PublishRelay<Void>()
    let tapSignOut = PublishRelay<Void>()
    
    let mypageViewModel: MypageViewModel
    weak var delegate: MypageViewControllerDelegate?
    
    init(mypageViewModel: MypageViewModel) {
        self.mypageViewModel = mypageViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
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
        
        let input = MypageViewModel.Input(
            viewWillAppear: viewWillAppear,
            tapUnavilableBox: tapGesture.rx.event,
            tapNotification: tapNotification,
            tapInquery: tapInquery,
            tapVersion: tapVersion,
            tapPolicy: tapPolicy,
            tapOpenSourceLicense: tapOpenSourceLicense,
            tapLogout: tapLogout,
            tapSignOut: tapSignOut
        )
        let output = mypageViewModel.transform(input: input)
        
        output.showUsedGifticonCount
            .drive(self.unavailableBox.countLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.tapUnavilableBox
            .emit(to: self.rx.showUnavailableGifticon)
            .disposed(by: disposeBag)
        
        output.showNotificationSetting
            .emit(to: self.rx.showNotificationSetting)
            .disposed(by: disposeBag)
        
        output.showInqueryAlert
            .emit(to: self.rx.showInqueryAlert)
            .disposed(by: disposeBag)
        
        output.showVersion
            .emit(to: self.rx.showVersion)
            .disposed(by: disposeBag)
        
        output.showPolicy
            .emit(to: self.rx.showPolicy)
            .disposed(by: disposeBag)
        
        output.showOpenSourceLicense
            .emit(to: self.rx.showOpenSOurceLicense)
            .disposed(by: disposeBag)
        
        output.showLogoutAlert
            .emit(to: self.rx.showLogougAlert)
            .disposed(by: disposeBag)
        
        output.showSignOut
            .emit(to: self.rx.showSignOut)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: MypageViewController {
    var showUnavailableGifticon: Binder<Void> {
        return Binder(base) { viewController, _ in
            MOALogger.logd()
            viewController.delegate?.navigateToUnavailableGifticon()
        }
    }
    
    var showNotificationSetting: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.delegate?.navigateToNotificationSetting()
        }
    }
    
    var showInqueryAlert: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            if MFMailComposeViewController.canSendMail() {
                viewController.delegate?.navigateToMailCompose()
            } else {
                viewController.showAlertModal(
                    title: MOA_CANT_INQUERY_TITLE,
                    subTitle: MOA_CANT_INQUERY_SUBTITLE,
                    confirmText: CONFIRM
                )
            }
        }
    }
    
    var showVersion: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.delegate?.navigateToVersion()
        }
    }
    
    var showPolicy: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.delegate?.navigateToPolicy()
        }
    }
    
    var showOpenSOurceLicense: Binder<Void> {
        return Binder<Void>(self.base) { viewContoller, _ in
            MOALogger.logd()
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    var showLogougAlert: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.showSelectModal(
                title: LOGOUT_ALERT_TITLE,
                subTitle: LOGOUT_ALERT_SUBTITLE,
                confirmText: LOGOUT_CONFIRM_BUTTON_TITLE,
                cancelText: LOGOUT_CANCEL_BUTTON_TITLE
            ) {
                let auth = Auth.auth()
                do {
                    NotificationManager.shared.removeAll()
                    try auth.signOut()
                    viewController.delegate?.navigateToLoginFromLogout()
                } catch let error as NSError {
                    MOALogger.loge("\(error.localizedDescription)")
                }
            }
        }
    }
    
    var showSignOut: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            NotificationManager.shared.removeAll()
            viewController.delegate?.navigateToWithDraw()
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
                tapNotification.accept(())
            case .Inquery:
                tapInquery.accept(())
            case .Version:
                tapVersion.accept(())
            case .Policy:
                tapPolicy.accept(())
            case .OpenSourceLicense:
                tapOpenSourceLicense.accept(())
            case .Logout:
                tapLogout.accept(())
            case .SignOut:
                tapSignOut.accept(())
            }
        }
    }
}
