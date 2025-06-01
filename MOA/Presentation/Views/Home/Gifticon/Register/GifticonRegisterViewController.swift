//
//  GifticonRegisterViewController.swift
//  MOA
//
//  Created by 오원석 on 11/23/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

protocol GifticonRegisterViewControllerDelegate: AnyObject {
    func navigateToFullGifticonImage(image: UIImage?)
    func navigateBack()
    func navigateRegisterLoading()
    func navigateToGifticonDetail(gifticonId: String, isRegistered: Bool)
}

final class GifticonRegisterViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private lazy var imageZoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ZOOM_IN_BUTTON), for: .normal)
        return button
    }()
    
    private let cancelButton: CommonButton = {
        let button = CommonButton(status: .cancel, title: CANCEL)
        return button
    }()
    
    private let saveButton: CommonButton = {
        let button = CommonButton(title: SAVE)
        return button
    }()
    
    let nameInputView: RegisterInputView = {
        let inputView = RegisterInputView(inputType: .name)
        return inputView
    }()
    
    let expireDateInputView: RegisterInputView = {
        let inputView = RegisterInputView(inputType: .expireDate)
        return inputView
    }()
    
    let storeInputView: RegisterInputView = {
        let inputView = RegisterInputView(inputType: .store)
        return inputView
    }()
    
    let memoInputView: RegisterInputView = {
        let inputView = RegisterInputView(inputType: .memo)
        return inputView
    }()
    
    var image: UIImage?
    
    let registerGifticon = PublishRelay<(UIImage, String, String, String, String?)>()
    
    let viewModel: GifticonRegisterViewModel
    
    weak var delegate: GifticonRegisterViewControllerDelegate?
    
    init(
        viewModel: GifticonRegisterViewModel,
        image: UIImage
    ) {
        self.viewModel = viewModel
        self.image = image
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Toast.shared.show(message: GIFTICON_REGISTER_TOAST_MESSAGE)
    }
}

private extension GifticonRegisterViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: GIFTICON_REGISTER_TITLE)
        
        [scrollView, cancelButton, saveButton].forEach {
            view.addSubview($0)
        }
        
        let buttonW = UIScreen.getWidthByDivision(division: 2, exclude: 48)
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
            $0.width.equalTo(buttonW)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(buttonW)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.top).offset(-16)
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
            memoInputView
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
            $0.bottom.equalToSuperview()
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
        
        let input = GifticonRegisterViewModel.Input(
            tapCancel: cancelButton.rx.tap,
            tapImageZoomIn: imageZoomInButton.rx.tap,
            tapSave: saveButton.rx.tap,
            registerGifticon: registerGifticon
        )
        
        let output = viewModel.transform(input: input)
        
        output.showCancelAlert
            .emit(to: self.rx.tapCancel)
            .disposed(by: disposeBag)

        output.showFullGifticonImage
            .emit(to: self.rx.tapZoomInImage)
            .disposed(by: disposeBag)
        
        output.isCheckRegister
            .emit(to: self.rx.tapSave)
            .disposed(by: disposeBag)
        
        output.loadingRegister
            .emit(to: self.rx.showLoadingRegister)
            .disposed(by: disposeBag)
        
        output.registerSuccess
            .emit(to: self.rx.navigateGifticonDetail)
            .disposed(by: disposeBag)
        
        output.registerFail
            .emit(to: self.rx.showRegisterFailAlert)
            .disposed(by: disposeBag)
    }
}

private extension Reactive where Base: GifticonRegisterViewController {
    var tapCancel: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.showSelectModal(
                title: GIFTICON_REGISTER_STOP_TITLE,
                confirmText: GIFTICON_REGISTER_STOP_CONFIRM_TEXT,
                cancelText: GIFTICON_REGISTER_STOP_CONTINUE_TEXT
            ) {
                viewController.delegate?.navigateBack()
            }
        }
    }
    
    var tapZoomInImage: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            viewController.delegate?.navigateToFullGifticonImage(image: viewController.image)
        }
    }
    
    var showLoadingRegister: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            viewController.delegate?.navigateRegisterLoading()
        }
    }
    
    var navigateGifticonDetail: Binder<String> {
        return Binder<String>(self.base) { viewController, gifticonId in
            viewController.dismiss(animated: false)
            viewController.delegate?.navigateToGifticonDetail(
                gifticonId: gifticonId,
                isRegistered: true
            )
        }
    }
    
    var showRegisterFailAlert: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            viewController.dismiss(animated: false)
            viewController.showAlertModal(
                title: GIFTICON_REGISTER_ERROR_POPUP_TITLE,
                subTitle: GIFTICON_REGISTER_ERROR_POPUP_SUBTITLE,
                confirmText: CONFIRM
            )
        }
    }
    
    var tapSave: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            guard let image = viewController.image else { return }
            guard let name = viewController.nameInputView.requestInput else { return }
            if name.count == 0 {
                viewController.showAlertModal(
                    title: GIFTICON_REGISTER_EMPTY_NAME_MODAL_TITLE,
                    confirmText: CONFIRM
                )
                return
            }
            
            if name.count > 16 {
                viewController.showAlertModal(
                    title: GIFTICON_REGISTER_MAX_LENGTH_MODAL_TITLE,
                    subTitle: GIFTICON_REGISTER_MAX_LENGTH_NAME_MODAL_SUBTITLE,
                    confirmText: CONFIRM
                )
                return
            }
            
            guard let expireDate = viewController.expireDateInputView.requestInput else {
                viewController.showAlertModal(
                    title: GIFTICON_REGISTER_EMPTY_EXPIRE_DATE_MODAL_TITLE,
                    confirmText: CONFIRM
                )
                return
            }
            guard let gifticonStore = viewController.storeInputView.requestInput else {
                viewController.showAlertModal(
                    title: GIFTICON_REGISTER_EMPTY_STORE_MODAL_TITLE,
                    confirmText: CONFIRM
                )
                return
            }
            let memo = viewController.memoInputView.requestInput
            if let memo = memo, memo.count > 50 {
                viewController.showAlertModal(
                    title: GIFTICON_REGISTER_MAX_LENGTH_MODAL_TITLE,
                    subTitle: GIFTICON_REGISTER_MAX_LENGTH_MEMO_MODAL_SUBTITLE,
                    confirmText: CONFIRM
                )
                return
            }
            
            viewController.registerGifticon.accept((image, name, expireDate, gifticonStore, memo))
        }
    }
}

extension GifticonRegisterViewController {
    @objc func keyboardWillAppear(sender: Notification) {
        MOALogger.logd()
        guard UIApplication.shared.topViewController is GifticonRegisterViewController else { return }
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.size.height - 96
        
        // contentInset을 통해서 Inset 을 주어 강제로 스크롤 되게 만듬
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollRectToVisible(memoInputView.frame, animated: true)
    }
    
    @objc func keyboardWillDisAppear(sender: Notification) {
        MOALogger.logd()
        guard UIApplication.shared.topViewController is GifticonRegisterViewController else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
