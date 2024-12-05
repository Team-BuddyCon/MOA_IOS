//
//  BottomSheetViewController.swift
//  MOA
//
//  Created by 오원석 on 11/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class BottomSheetViewController: BaseViewController {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    var delegate: BottomSheetDelegate?
    private var sheetType: BottomSheetType {
        didSet {
            updateBottomSheet()
        }
    }
    
    private var sortType: SortType?
    private var date: Date = Date()
    
    init(
        sheetType: BottomSheetType,
        sortType: SortType? = nil,
        date: Date = Date()
    ) {
        self.sheetType = sheetType
        self.sortType = sortType
        self.date = date
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        startAnimation()
        bind()
    }
}

private extension BottomSheetViewController {
    func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(contentView)
        updateBottomSheet()
        
        switch sheetType {
        case .Sort:
            setupSortBottomSheet()
        case .Date:
            setupDateBottomSheet()
        case .Store:
            setupStoreBottomSheet()
        case .Other_Store:
            setupOtherStoreBottomSheet()
        }
    }
    
    func setupSortBottomSheet() {
        let sheetView = SortBottomSheetView(type: sortType ?? .EXPIRE_DATE)
        contentView.addSubview(sheetView)
        
        sheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sheetView.sortType
            .emit(onNext: { [weak self] type in
                self?.delegate?.selectSortType(type: type)
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    func setupDateBottomSheet() {
        let sheetView = ExpireDateSheetView(date: date)
        contentView.addSubview(sheetView)
        
        sheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sheetView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let date = sheetView.datePicker.date
                self?.delegate?.selectDate(date: date)
            }).disposed(by: disposeBag)
    }
    
    func setupStoreBottomSheet() {
        let sheetView = StoreSheetView()
        
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        contentView.addSubview(sheetView)
        
        sheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sheetView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            }).disposed(by: disposeBag)
        
        sheetView.storeCollectionView.rx.modelSelected(StoreType.self)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                
                switch type {
                case .OTHERS:
                    sheetType = .Other_Store
                    setupOtherStoreBottomSheet()
                default:
                    delegate?.selectStore(store: type.rawValue)
                }
            }).disposed(by: disposeBag)
    }
    
    func setupOtherStoreBottomSheet() {
        let sheetView = OtherStoreSheetView()
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        contentView.addSubview(sheetView)
        
        sheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sheetView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            }).disposed(by: disposeBag)
        
        sheetView.prevButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                sheetType = .Store
                setupStoreBottomSheet()
            }).disposed(by: disposeBag)
        
        sheetView.completeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let text = sheetView.textInput.text ?? ""
                delegate?.selectStore(store: "기타 - \(text)")
            }).disposed(by: disposeBag)
    }
    
    func updateBottomSheet() {
        contentView.snp.updateConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(self.sheetType.rawValue)
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    // TODO : 추후 애니메이션 정상 동작하도록 변경
    func startAnimation() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut]
        ) { [weak self] in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            contentView.snp.updateConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(self.sheetType.rawValue)
                $0.bottom.equalToSuperview().offset(0)
            }
            contentView.layoutIfNeeded()
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
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        dismissTapGesture.delegate = self
        view.addGestureRecognizer(dismissTapGesture)
    }
}

// MARK: UIGestureRecognizerDelegate
extension BottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        MOALogger.logd()
        guard touch.view?.isDescendant(of: self.contentView) == false else { return false }
        return true
    }
}

// MARK: objective-C
extension BottomSheetViewController {
    @objc func tapDismiss() {
        MOALogger.logd()
        dismiss(animated: true)
    }
    
    @objc func keyboardWillAppear(sender: Notification) {
        MOALogger.logd()
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let keyboardDuration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        UIView.animate(
            withDuration: keyboardDuration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                guard let self = self else { return }
                contentView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().inset(keyboardHeight)
                }
                view.layoutIfNeeded()
            })
    }
    
    @objc func keyboardWillDisAppear(sender: Notification) {
        MOALogger.logd()
        guard let keyboardDuration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(
            withDuration: keyboardDuration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                guard let self = self else { return }
                contentView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(0)
                }
                contentView.layoutIfNeeded()
            })
    }
}
