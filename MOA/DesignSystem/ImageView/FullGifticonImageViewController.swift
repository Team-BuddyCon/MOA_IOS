//
//  FullGifticonImageView.swift
//  MOA
//
//  Created by 오원석 on 12/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class FullGifticonImageViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true    // imageView는 기본적으로 false로 설정되어 UIView가 이벤트 받음
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CLOSE_BUTTON)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }
    
    private func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        [imageView, closeButton].forEach {
            view.addSubview($0)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(58)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(58)
        }
    }
    
    private func bind() {
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapClose))
        closeTapGesture.delegate = self
        view.addGestureRecognizer(closeTapGesture)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.tapClose()
            }).disposed(by: disposeBag)
    }
    
    @objc func tapClose() {
        MOALogger.logd()
        dismiss(animated: true)
    }
}

extension FullGifticonImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == imageView || touch.view == closeButton {
            return false
        }
        return true
    }
}
