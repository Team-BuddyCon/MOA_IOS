//
//  ModalViewController.swift
//  MOA
//
//  Created by 오원석 on 11/20/24.
//

import UIKit
import SnapKit

final class ModalViewController: BaseViewController {
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.textAlignment = .center
        label.textColor = .grey90
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grey70
        label.numberOfLines = 2
        label.isHidden = modalType == .alert || modalType == .select
        return label
    }()
    
    private lazy var cancelButton: CommonButton = {
        let button = CommonButton(status: .cancel, title: cancelText ?? "", fontSize: 14.0)
        button.isHidden = modalType == .alert || modalType == .alertDetail
        button.addTarget(self, action: #selector(tapDismiss), for: .touchUpInside)
        return button
    }()
    
    private lazy var activeButton: CommonButton = {
        let button = CommonButton(status: .active, title: confirmText ?? "", fontSize: 14.0)
        button.isHidden = modalType == .alert || modalType == .alertDetail
        button.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: CommonButton = {
        let button = CommonButton(status: .active, title: confirmText ?? "", fontSize: 14.0)
        button.isHidden = modalType == .select || modalType == .selectDetail
        button.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
        return button
    }()
    
    private var cancelText: String?
    private var confirmText: String?
    private let modalType: ModalType
    private let onConfirm: () -> Void
    
    init(
        modalType: ModalType,
        title: String,
        subTitle: String? = nil,
        confirmText: String,
        cancelText: String? = nil,
        onConfirm: @escaping () -> Void = {}
    ) {
        self.modalType = modalType
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        titleLabel.text = title
        
        if let subTitle = subTitle {
            subTitleLabel.setTextWithLineHeight(
                text: subTitle,
                font: pretendard_regular,
                size: 12.0,
                lineSpacing: 16.8
            )
        }

        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 20
        
        [titleLabel, subTitleLabel].forEach {
            titleContentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        titleView.addSubview(titleContentView)
        titleContentView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        [
            titleView,
            cancelButton,
            activeButton,
            confirmButton
        ].forEach {
            contentView.addSubview($0)
        }
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(38)
            $0.height.equalTo(170)
        }
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(94)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.height.equalTo(44)
        }
        
        // 38 + 38 + 32 + 8
        let buttonW = (view.frame.size.width - 116) / 2
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.height.equalTo(44)
            $0.width.equalTo(buttonW)
        }
        
        activeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.height.equalTo(44)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
            $0.width.equalTo(buttonW)
        }
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        dismissTapGesture.delegate = self
        view.addGestureRecognizer(dismissTapGesture)
    }
    
    @objc private func tapDismiss() {
        MOALogger.logd()
        dismiss(animated: true)
    }
    
    @objc private func tapConfirm() {
        MOALogger.logd()
        dismiss(animated: true) { [weak self] in
            self?.onConfirm()
        }
    }
}

extension ModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == contentView {
            return false
        }
        return true
    }
}

extension UIViewController {
    func showAlertModal(
        title: String,
        subTitle: String? = nil,
        confirmText: String,
        onConfirm: @escaping () -> Void = {}
    ) {
        let modalType = subTitle == nil ? ModalType.alert : ModalType.alertDetail
        let modalVC = ModalViewController(
            modalType: modalType,
            title: title,
            subTitle: subTitle,
            confirmText: confirmText,
            onConfirm: onConfirm
        )
        present(modalVC, animated: true)
    }
    
    func showSelectModal(
        title: String,
        subTitle: String? = nil,
        confirmText: String,
        cancelText: String,
        onConfirm: @escaping () -> Void = {}
    ) {
        let modalType = subTitle == nil ? ModalType.select : ModalType.selectDetail
        let modalVC = ModalViewController(
            modalType: modalType,
            title: title,
            subTitle: subTitle,
            confirmText: confirmText,
            cancelText: cancelText,
            onConfirm: onConfirm
        )
        present(modalVC, animated: true)
    }
}
