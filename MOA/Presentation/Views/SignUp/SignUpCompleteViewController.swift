//
//  SignUpCompleteViewController.swift
//  MOA
//
//  Created by 오원석 on 10/23/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

protocol SignUpCompleteViewControllerDelegate: AnyObject {
    func navigateToHome()
}

final class SignUpCompleteViewController: BaseViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: SIGNUP_COMPLETE_ICON_ASSET))
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 30.0)
        label.setRangeFontColor(text: SIGNUP_COMPLETE_TITLE, startIndex: 0, endIndex: 4, color: .pink100)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(
            text: String(format: SIGNUP_COMPLETE_SUBTITLE_FORMAT, UserPreferences.getLoginUserName()),
            font: pretendard_medium,
            size: 16.0,
            lineSpacing: 22.4,
            alignment: .left
        )
        label.numberOfLines = 2
        label.textColor = .grey90
        return label
    }()
    
    let startButton: CommonButton = {
        let button = CommonButton(title: LETS_START, fontSize: 16.0)
        return button
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    weak var delegate: SignUpCompleteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
    
    private func setupLayout() {
        [imageView, titleLabel, subTitleLabel].forEach {
            infoView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.size.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        [infoView, startButton].forEach {
            view.addSubview($0)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(280)
            $0.bottom.equalToSuperview().inset(360)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
        }
    }
    
    private func bind() {
        startButton.rx.tap
            .asSignal()
            .emit(to: self.rx.startButtonTapped)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: SignUpCompleteViewController {
    var startButtonTapped: Binder<Void> {
        return Binder(self.base) { viewController, _ in
            UserPreferences.setSignUp(sign: true)
            viewController.delegate?.navigateToHome()
        }
    }
}
