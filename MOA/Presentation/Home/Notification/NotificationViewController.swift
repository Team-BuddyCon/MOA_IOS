//
//  NotificationDataViewController.swift
//  MOA
//
//  Created by 오원석 on 3/8/25.
//

import UIKit

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
    
    private let viewModel = NotificationViewModel()
    
    private var eventID: String?
    
    init(eventID: String? = nil) {
        self.eventID = eventID
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
            onNext: { [unowned self] notifications in
                MOALogger.logd("\(notifications)")
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
        // 단일
        if notificationModel.count == 1 {
            UIApplication.shared.navigationGifticonDetail(gifticonId: notificationModel.gifticonId)
        } else {
            UIApplication.shared.navigationHome()
        }
    }
}
