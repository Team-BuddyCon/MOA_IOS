//
//  NotificationInfoViewCell.swift
//  MOA
//
//  Created by 오원석 on 3/8/25.
//

import UIKit

protocol NotificationInfoViewCellDelegate {
    func tapInfoView(notificationModel: NotificationModel)
}

final class NotificationInfoViewCell: UITableViewCell {
    static let identifier = "NotificationInfoViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: NOTIFICATION_GIFTICON_ICON)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = GIFTICON
        label.font = UIFont(name: pretendard_regular, size: 13.0)
        label.textColor = .grey60
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 13.0)
        label.textColor = .grey50
        return label
    }()
    
    private let msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grey90
        label.numberOfLines = 0
        return label
    }()
    
    var delegate: NotificationInfoViewCellDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var notificationModel: NotificationModel?
    
    func setNotificationInfo(_ notificationModel: NotificationModel, highlight: Bool = false) {
        self.notificationModel = notificationModel
        msgLabel.setTextWithLineHeight(
            text: notificationModel.message,
            font: pretendard_medium,
            size: 15.0,
            lineSpacing: 21.0,
            alignment: .left
        )
        backgroundColor = highlight == true ? .pink20 : .white
        
        let dday = abs(notificationModel.date.toDday())
        if dday == 0 {
            let dtime = abs(notificationModel.date.toDTime())
            dateLabel.text = "\(dtime)시간 전"
        } else {
            dateLabel.text = "\(dday)일 전"
        }
    }
    
    func setMessage(_ message: String, highlight: Bool = false) {
        msgLabel.setTextWithLineHeight(
            text: message,
            font: pretendard_medium,
            size: 15.0,
            lineSpacing: 21.0,
            alignment: .left
        )
        backgroundColor = highlight == true ? .pink20 : .white
    }
}

private extension NotificationInfoViewCell {
    func setupLayout() {
        [
            iconImageView,
            titleLabel,
            dateLabel,
            msgLabel
        ].forEach {
            addSubview($0)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top)
            $0.bottom.equalTo(iconImageView.snp.bottom)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        msgLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func bind() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        addGestureRecognizer(tapGesture)
    }
}

extension NotificationInfoViewCell {
    @objc func tapCell() {
        if let notificationModel = notificationModel {
            delegate?.tapInfoView(notificationModel: notificationModel)
        }
    }
}
