//
//  NotificationDataViewController.swift
//  MOA
//
//  Created by 오원석 on 3/8/25.
//

import UIKit

final class NotificationDataViewController: BaseViewController {
    
    private let mocks: [NotificationModel] = [
        NotificationModel(count: 1, date: "2025.01.03", message: "'마왕족발' 기프티콘이 오늘 만료되어요.\n지금 바로 사용하러 가볼까요?", gifticonId: ""),
        NotificationModel(count: 2, date: "2025.03.03", message: "'마왕족발' 기프티콘이 오늘 만료되어요.\n지금 바로 사용하러 가볼까요?", gifticonId: ""),
        NotificationModel(count: 1, date: "2025.03.10", message: "'마왕족발' 기프티콘이 오늘 만료되어요.\n지금 바로 사용하러 가볼까요?", gifticonId: ""),
        NotificationModel(count: 5, date: "2025.02.03", message: "'마왕족발' 기프티콘이 오늘 만료되어요.\n지금 바로 사용하러 가볼까요?", gifticonId: "")
    ]
    
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
    }
    
}

private extension NotificationDataViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: NOTIFICATION)
        
        view.addSubview(notificationTableView)
        
        notificationTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NotificationDataViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationInfoViewCell.identifier, for: indexPath) as? NotificationInfoViewCell else {
            return UITableViewCell()
        }
        
        let mock = mocks[indexPath.row]
        cell.setNotificationInfo(mock, highlight: indexPath.row == 0)
        return cell
    }
}
