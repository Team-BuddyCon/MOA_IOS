//
//  BottomSheetViewController.swift
//  MOA
//
//  Created by 오원석 on 6/3/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

class BottomSheetViewController : UIViewController, UIGestureRecognizerDelegate {
    
    lazy var contentView: UIView = {
        let view = UIView()
        let width = Int(UIScreen.main.bounds.width)
        let height = sheetType.height
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    var delegate: BottomSheetViewControllerDelegate?
    
    var sheetType: BottomSheetType
    
    init(sheetType: BottomSheetType) {
        self.sheetType = sheetType
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
    
    func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(contentView)
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
                $0.height.equalTo(self.sheetType.height)
                $0.bottom.equalToSuperview().offset(0)
            }
            contentView.layoutIfNeeded()
        }
    }
    
    // contentView 외부 터치 시에 바텀시트 dismiss
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        MOALogger.logd()
        guard touch.view?.isDescendant(of: self.contentView) == false else { return false }
        return true
    }
    
    @objc func tapDismiss() {
        MOALogger.logd()
        delegate?.dismiss?()
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
