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

final class MypageViewController: BaseViewController {
    
    let menus = MenuType.allCases
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(
            text:  "안녕하세요,\n오원석님!",
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
        mypageViewModel.fetchGifticonCount()
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
        
        mypageViewModel.count
            .map { String(format: UNAVAILABLE_GIFTICON_COUNT_FORMAT, $0) }
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
    
    var bindUnavailableGifticonCount: Binder<Int> {
        return Binder(base) { viewController, count in
            MOALogger.logd()
            
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
            case .Logout:
                showSelectModal(
                    title: LOGOUT_ALERT_TITLE,
                    subTitle: LOGOUT_ALERT_SUBTITLE,
                    confirmText: LOGOUT_CONFIRM_BUTTON_TITLE,
                    cancelText: LOGOUT_CANCEL_BUTTON_TITLE
                )
            case .SignOut:
                showAlertModal(
                    title: PREPARATION_FEATURE_ALERT_TITLE,
                    subTitle: PREPARATION_FEATURE_ALERT_SUBTITLE,
                    confirmText: CONFIRM
                )
            default:
                break
            }
        }
    }
}
