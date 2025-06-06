//
//  StoreBottomSheetViewController.swift
//  MOA
//
//  Created by 오원석 on 6/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class StoreBottomSheetViewController: BottomSheetViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.text = STORE
        label.textColor = .grey90
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CLOSE_BUTTON), for: .normal)
        return button
    }()
    
    private let storeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 21
        
        let itemWidth = UIScreen.getWidthByDivision(division: 4, exclude: 103)
        layout.itemSize = CGSize(width: itemWidth, height: 102)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20)
            
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StoreTypeCell.self, forCellWithReuseIdentifier: StoreTypeCell.identifier)
        return collectionView
    }()
    
    private let storeTypes = BehaviorRelay(value: Array(StoreType.allCases.dropFirst()))
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: OTHERS_IMAGE)
        imageView.isHidden = true
        return imageView
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_medium, size: 14.0)
        label.textColor = .grey90
        label.text = GIFTICON_REGISTER_OTHER_STORE_GUIDE
        label.isHidden = true
        return label
    }()
    
    private lazy var textInput: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: pretendard_bold, size: 15.0)
        textField.textColor = .grey90
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.placeholder = GIFTICON_REGISTER_OTHER_STORE_PLACEHOLDER
        textField.underLine(width: 1.0, color: .grey30)
        textField.delegate = self
        textField.isHidden = true
        return textField
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .grey60
        label.text = GIFTICON_REGISTER_OTHER_STORE_INFO
        label.isHidden = true
        return label
    }()
    
    private let prevButton: CommonButton = {
        let button = CommonButton(
            status: .cancel,
            title: GIFTICON_REGISTER_OTHER_STORE_PREVIOUS_BUTTON
        )
        button.isHidden = true
        return button
    }()
    
    private let completeButton: CommonButton = {
        let button = CommonButton(
            status: .active,
            title: GIFTICON_REGISTER_OTHER_STORE_COMPLETED
        )
        button.isHidden = true
        return button
    }()
    
    override var sheetType: BottomSheetType {
        didSet {
            storeCollectionView.isHidden = sheetType == .Other_Store
            iconImageView.isHidden = sheetType == .Store
            guideLabel.isHidden = sheetType == .Store
            textInput.isHidden = sheetType == .Store
            infoLabel.isHidden = sheetType == .Store
            prevButton.isHidden = sheetType == .Store
            completeButton.isHidden = sheetType == .Store
            
            contentView.snp.updateConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(self.sheetType.rawValue)
                $0.bottom.equalToSuperview().offset(0)
            }
            contentView.layoutIfNeeded()
        }
    }
    
    init() {
        super.init(sheetType: .Store)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        [
            titleLabel,
            closeButton,
            storeCollectionView,
            iconImageView,
            guideLabel,
            textInput,
            infoLabel,
            prevButton,
            completeButton
        ].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(19)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        
        storeCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(68)
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(40)
        }
        
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom)
            $0.leading.equalToSuperview().inset(20)
        }
        
        textInput.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(21)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(textInput.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        let buttonW = UIScreen.getWidthByDivision(division: 2, exclude: 48)
        prevButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(buttonW)
            $0.height.equalTo(54)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
        
        completeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(buttonW)
            $0.height.equalTo(54)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
    }
    
    override func bind() {
        super.bind()
        
        storeTypes.bind(to: storeCollectionView.rx.items(
            cellIdentifier: StoreTypeCell.identifier,
            cellType: StoreTypeCell.self)
        ) { row, storeType, cell in
            cell.setData(storeType: storeType)
        }.disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            }).disposed(by: disposeBag)
        
        storeCollectionView.rx.modelSelected(StoreType.self)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                
                switch type {
                case .OTHERS:
                    sheetType = .Other_Store
                default:
                    guard let delegate = delegate as? StoreBottomSheetViewControllerDelegate else { return }
                    delegate.didSelectStore(store: type)
                }
            }).disposed(by: disposeBag)
        
        
        prevButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                sheetType = .Store
            }).disposed(by: disposeBag)
        
        completeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let store = textInput.text ?? ""
                
                guard let delegate = delegate as? StoreBottomSheetViewControllerDelegate else { return }
                delegate.didSelectOther(store: store)
            }).disposed(by: disposeBag)
    }
}

extension StoreBottomSheetViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        textInput.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let text = (currentText as NSString).replacingCharacters(in: range, with: string)
        return text.count <= 23
    }
}
