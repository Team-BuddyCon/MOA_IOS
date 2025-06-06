//
//  RegisterInputView.swift
//  MOA
//
//  Created by 오원석 on 11/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

enum InputType {
    case name
    case expireDate
    case store
    case memo
    
    var title: String {
        switch self {
        case .name: return GIFTICON_REGSITER_NAME_INPUT_TITLE
        case .expireDate: return GIFTICON_REGISTER_EXPIRE_DATE_INPUT_TITLE
        case .store: return GIFTICON_REGISTER_STORE_INPUT_TITLE
        case .memo: return GIFTICON_REGISTER_MEMO_INPUT_TITLE
        }
    }
    
    var hint: String {
        switch self {
        case .name: return GIFTICON_REGISTER_NAME_INPUT_HINT
        case .expireDate: return GIFTICON_REGISTER_EXPIRE_DATE_INPUT_HINT
        case .store: return GIFTICON_REGISTER_STORE_INPUT_HINT
        case .memo: return GIFTICON_REGISTER_MEMO_INPUT_HINT
        }
    }
    
    var isMandatory: Bool {
        self != .memo
    }
    
    var hasIcon: Bool {
        self == .expireDate || self == .store
    }
    
    var icon: UIImage? {
        switch self {
        case .expireDate: return UIImage(named: EXPIRE_DATE_INPUT_ICON)
        case .store: return UIImage(named: STORE_INPUT_ICON)
        default: return nil
        }
    }
}

final class RegisterInputView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 13.0)
        label.textColor = .grey70
        return label
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 15.0)
        label.textColor = .grey40
        label.text = inputType.hint
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: pretendard_bold, size: 15.0)
        textField.textColor = .grey90
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.isHidden = inputType == .expireDate || inputType == .store
        textField.delegate = self
        return textField
    }()
    
    private lazy var inputLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .grey90
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = !inputType.hasIcon
        imageView.image = inputType.icon
        return imageView
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey30
        return view
    }()
    
    private var hasInput: Bool = false {
        didSet {
            hintLabel.isHidden = hasInput
            inputLabel.isHidden = !hasInput
            inputTextField.isHidden = hasInput ? hasInput : (inputType == .expireDate || inputType == .store)
        }
    }
    private var inputType: InputType
    private var selectDate: Date = Date()
    var requestInput: String? = nil
    
    init(
        inputType: InputType,
        hasInput: Bool = false,
        name: String? = nil,
        expireDate: Date? = nil,
        gifticonStore: StoreType? = nil,
        memo: String? = nil
    ) {
        self.inputType = inputType
        super.init(frame: .zero)
        self.hasInput = hasInput

        // inputType 필수 여부 확인하여 UI 표기(*)
        if inputType.isMandatory {
            titleLabel.setRangeFontColor(
                text: "\(inputType.title)*",
                startIndex: inputType.title.count,
                endIndex: inputType.title.count + 1,
                color: .pink100
            )
        } else {
            titleLabel.text = inputType.title
        }
        
        setupLayout()
        bind()
        
        // 이미 값이 있는 경우
        if hasInput {
            setData(name: name, expireDate: expireDate, store: gifticonStore, memo: memo)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [titleLabel, hintLabel, inputTextField, inputLabel, iconView, lineView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        hintLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        inputTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        inputLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        iconView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(hintLabel.snp.centerY)
            $0.size.equalTo(24)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(hintLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func setData(
        name: String?,
        expireDate: Date?,
        store: StoreType?,
        memo: String?
    ) {
        hintLabel.isHidden = true
        inputLabel.isHidden = false
        inputTextField.isHidden = (inputType == .expireDate || inputType == .store)
        
        if let name = name {
            requestInput = name
            inputTextField.text = name
            return
        }
        
        if let expireDate = expireDate {
            selectDate = expireDate
            requestInput = expireDate.toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
            inputLabel.text = expireDate.toString(format: AVAILABLE_GIFTICON_TIME_FORMAT)
            return
        }
        
        if let store = store {
            requestInput = store.code
            inputLabel.text = store.rawValue
            return
        }
        
        if let memo = memo {
            requestInput = memo
            inputTextField.text = memo
        }
    }
    
    private func bind() {
        let hintTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapInput))
        let inputTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapInput))
        hintLabel.addGestureRecognizer(hintTapGesture)
        inputLabel.addGestureRecognizer(inputTapGesture)
        
        inputTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                hintLabel.isHidden = text?.isEmpty == false
                
                if inputType == .name || inputType == .memo {
                    requestInput = text
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func tapInput() {
        MOALogger.logd("\(inputType.title)")
        
        switch inputType {
        case .expireDate:
            let topVC = UIApplication.shared.topViewController
            let expireDateBottomSheet = ExpireDateBottomSheetViewController(date: selectDate)
            expireDateBottomSheet.delegate = self
            topVC?.present(expireDateBottomSheet, animated: true)
        case .store:
            let topVC = UIApplication.shared.topViewController
            let storeBottomSheet = StoreBottomSheetViewController()
            storeBottomSheet.delegate = self
            topVC?.present(storeBottomSheet, animated: true)
        default:
            break
        }
    }
}

extension RegisterInputView: StoreBottomSheetViewControllerDelegate, ExpireDateBottomSheetViewControllerDelegate {
    func didSelectStore(store: StoreType) {
        MOALogger.logd(store.rawValue)
        hasInput = true
        inputLabel.text = store.rawValue
        requestInput = store.code
        
        UIApplication.shared.topViewController?.dismiss(animated: false)
    }
    
    func didSelectOther(store: String) {
        MOALogger.logd("기타 - \(store)")
        let input = "기타" + (store.isEmpty ? "" : "- \(store)")
        
        hasInput = true
        inputLabel.text = input
        requestInput = StoreType.OTHERS.code
        
        UIApplication.shared.topViewController?.dismiss(animated: false)
    }
    
    func didSelectDate(date: Date) {
        MOALogger.logd("\(date)")
        hasInput = true
        selectDate = date
        
        let formatter = DateFormatter()
        formatter.dateFormat = AVAILABLE_GIFTICON_TIME_FORMAT
        inputLabel.text = formatter.string(from: date)
        requestInput = formatter.string(from: date)
        
        UIApplication.shared.topViewController?.dismiss(animated: false)
    }
}

extension RegisterInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }
}
