//
//  SortBottomSheetViewController.swift
//  MOA
//
//  Created by 오원석 on 6/3/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class SortBottomSheetViewController: BottomSheetViewController {
    
    private let sortType = BehaviorRelay<SortType>(value: .EXPIRE_DATE)
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        return view
    }()
    
    private let expirationButton: SortButton = {
        let button = SortButton(type: .EXPIRE_DATE)
        return button
    }()
    
    private let registrationButton: SortButton = {
        let button = SortButton(type: .CREATED_AT)
        return button
    }()
    
    private let nameButton: SortButton = {
        let button = SortButton(type: .NAME)
        return button
    }()
    
    override init(sheetType: BottomSheetType) {
        switch sheetType {
        case .Sort(let sortType):
            self.sortType.accept(sortType)
            
            switch sortType {
            case .EXPIRE_DATE:
                expirationButton.isSelected.accept(true)
            case .CREATED_AT:
                registrationButton.isSelected.accept(true)
            case .NAME:
                nameButton.isSelected.accept(true)
            }
            
            super.init(sheetType: sheetType)
        default:
            fatalError()
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        [indicatorView, expirationButton, registrationButton, nameButton].forEach {
            contentView.addSubview($0)
        }
        
        indicatorView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(4)
        }
        indicatorView.layer.cornerRadius = 2
        
        expirationButton.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(indicatorView.snp.bottom).offset(18)
            $0.height.equalTo(52)
        }
        
        registrationButton.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(expirationButton.snp.bottom).offset(8)
            $0.height.equalTo(52)
        }
        
        nameButton.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(registrationButton.snp.bottom).offset(8)
            $0.height.equalTo(52)
        }
    }
    
    override func bind() {
        super.bind()
        
        let sortButtons = contentView.subviews
            .filter { $0 is SortButton }
            .map { $0 as? SortButton }
        
        sortButtons.forEach {
            if let button = $0 {
                button.isSelected
                    .distinctUntilChanged()
                    .asSignal(onErrorJustReturn: false)
                    .emit(onNext: { [weak self] isSelect in
                        guard let self = self else {
                            MOALogger.loge()
                            return
                        }
                        
                        if isSelect {
                            sortType.accept(button.type)
                            sortButtons
                                .filter { $0 != button }
                                .forEach { $0?.isSelected.accept(false) }
                        }
                    }).disposed(by: disposeBag)
                }
            }
        
        sortType.subscribe(onNext: { [weak self] type in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            
            guard let delegate = self.delegate as? SortBottomSheetViewControllerDelegate else { return }
            delegate.didSelectSort(type: type)
            dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}
