//
//  GifticonEditViewController.swift
//  MOA
//
//  Created by 오원석 on 12/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class GifticonEditViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let completeButton: CommonButton = {
        let button = CommonButton(
            status: .active,
            title: COMPLETE
        )
        return button
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.image = gifticonImage
        return imageView
    }()
    
    private lazy var imageZoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ZOOM_IN_BUTTON), for: .normal)
        return button
    }()
    
    private lazy var nameInputView: RegisterInputView = {
        let inputView = RegisterInputView(
            inputType: .name,
            hasInput: true,
            name: detailGifticon.name
        )
        return inputView
    }()
    
    private lazy var expireDateInputView: RegisterInputView = {
        let inputView = RegisterInputView(
            inputType: .expireDate,
            hasInput: true,
            expireDate: detailGifticon.expireDate
        )
        return inputView
    }()
    
    private lazy var storeInputView: RegisterInputView = {
        let inputView = RegisterInputView(
            inputType: .store,
            hasInput: true,
            gifticonStore: detailGifticon.gifticonStore
        )
        return inputView
    }()
    
    private lazy var memoInputView: RegisterInputView = {
        let inputView = RegisterInputView(
            inputType: .memo,
            hasInput: true,
            memo: detailGifticon.memo
        )
        return inputView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.layer.cornerRadius = 8
        button.backgroundColor = .grey20
        button.setTitle(DELETE, for: .normal)
        button.setTitleColor(.grey50, for: .normal)
        button.setImage(UIImage(named: DELETE_BUTTON), for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_bold, size: 13.0)
        return button
    }()
    
    let detailGifticon: DetailGifticon
    let gifticonImage: UIImage?
    let gifticonEditViewModel = GifticonEditViewModel(gifticonService: GifticonService.shared)
    
    init(
        detailGifticon: DetailGifticon,
        gifticonImage: UIImage?
    ) {
        self.detailGifticon = detailGifticon
        self.gifticonImage = gifticonImage
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

private extension GifticonEditViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: GIFTICON_MENU_TITLE)
        
        [scrollView, completeButton].forEach {
            view.addSubview($0)
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(completeButton.snp.top).offset(-16)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        [
            imageView,
            imageZoomInButton,
            nameInputView,
            expireDateInputView,
            storeInputView,
            memoInputView,
            deleteButton
        ].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(imageView.snp.width).multipliedBy(328 / 335.0)
        }
        
        imageZoomInButton.snp.makeConstraints {
            $0.trailing.equalTo(imageView.snp.trailing).inset(16)
            $0.bottom.equalTo(imageView.snp.bottom).inset(16)
            $0.size.equalTo(40)
        }
        
        nameInputView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        expireDateInputView.snp.makeConstraints {
            $0.top.equalTo(nameInputView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        storeInputView.snp.makeConstraints {
            $0.top.equalTo(expireDateInputView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        memoInputView.snp.makeConstraints {
            $0.top.equalTo(storeInputView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(memoInputView.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(61)
            $0.height.equalTo(34)
        }
    }
    
    func bind() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisAppear),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        imageZoomInButton.rx.tap
            .bind(to: self.rx.tapZoomInImage)
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind(to: self.rx.tapDelete)
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(to: self.rx.tapComplete)
            .disposed(by: disposeBag)
    }
}

private extension Reactive where Base: GifticonEditViewController {
    var tapZoomInImage: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            let fullImageVC = FullGifticonImageViewController(image: viewController.gifticonImage)
            viewController.present(fullImageVC, animated: true)
        }
    }
    
    var tapDelete: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            let modalVC = ModalViewController(
                modalType: .select,
                title: GIFTICON_DELETE_MODAL_TITLE,
                confirmText: DELETE_MODAL,
                cancelText: CLOSE
            ) {
                
            }
            
            viewController.present(modalVC, animated: true)
        }
    }
    
    var tapComplete: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
        }
    }
}

extension GifticonEditViewController {
    @objc func keyboardWillAppear(sender: Notification) {
        MOALogger.logd()
        guard UIApplication.shared.topViewController is GifticonEditViewController else { return }
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.size.height - 96
        
        // contentInset을 통해서 Inset 을 주어 강제로 스크롤 되게 만듬
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollRectToVisible(memoInputView.frame, animated: true)
    }
    
    @objc func keyboardWillDisAppear(sender: Notification) {
        MOALogger.logd()
        guard UIApplication.shared.topViewController is GifticonEditViewController else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
