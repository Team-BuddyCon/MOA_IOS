//
//  NotificationDataViewController.swift
//  MOA
//
//  Created by 오원석 on 3/8/25.
//

import UIKit

protocol NotificationViewControllerDelegate: AnyObject {
    func navigateToNotificationDetail(isSingle: Bool, gifticonId: String)
}

final class NotificationViewController: BaseViewController {
    
    private lazy var notificationTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NotificationInfoViewCell.self, forCellReuseIdentifier: NotificationInfoViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 83
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        return tableView
    }()
    
    private let viewModel: NotificationViewModel
    
    weak var delegate: NotificationViewControllerDelegate?
    
    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
}

private extension NotificationViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: NOTIFICATION)
        
        view.addSubview(notificationTableView)
        
        notificationTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        viewModel.notificationsRelay.subscribe(
            onNext: { _ in
                let _ = LocalNotificationDataManager.shared.updateAllNotification()
            }
        ).disposed(by: disposeBag)
    }
}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifcationModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationInfoViewCell.identifier, for: indexPath) as? NotificationInfoViewCell else {
            return UITableViewCell()
        }
        
        let model = viewModel.notifcationModels[indexPath.row]
        cell.setNotificationInfo(model, highlight: !model.isRead)
        cell.delegate = self
        return cell
    }
}

extension NotificationViewController: NotificationInfoViewCellDelegate {
    func tapInfoView(notificationModel: NotificationModel) {
        self.delegate?.navigateToNotificationDetail(isSingle: notificationModel.count == 1, gifticonId: notificationModel.gifticonId)
    }
}
