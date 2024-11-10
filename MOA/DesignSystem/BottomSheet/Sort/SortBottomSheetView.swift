//
//  SortBottomSheetView.swift
//  MOA
//
//  Created by 오원석 on 11/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class SortBottomSheetView: UIView {
    private let disposeBag = DisposeBag()
    private let _type = BehaviorRelay(value: SortType.ExpirationPeriod)
    let type: Driver<SortType>
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        return view
    }()
    
    private lazy var expirationButton: SortButton = {
        let button = SortButton(type: .ExpirationPeriod)
        return button
    }()
    
    private lazy var registrationButton: SortButton = {
        let button = SortButton(type: .Registration)
        return button
    }()
    
    private lazy var nameButton: SortButton = {
        let button = SortButton(type: .Name)
        return button
    }()
    
    override init(frame: CGRect) {
        type = _type.asDriver(onErrorJustReturn: .ExpirationPeriod)
        super.init(frame: frame)
        setupLayout()
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        let width = Int(UIScreen.main.bounds.width)
        let heith = BottomSheetType.Sort.rawValue
        frame = CGRect(x: 0, y: 0, width: width, height: heith)
        layer.cornerRadius = 16
        backgroundColor = .white
        
        [indicatorView, expirationButton, registrationButton, nameButton].forEach {
            addSubview($0)
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
    
    func subscribe() {
        expirationButton.isSelected
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: false)
            .emit(onNext: { [weak self] isSelect in
                guard let self = self else {
                    return
                }
                if isSelect {
                    registrationButton.isSelected.accept(false)
                    nameButton.isSelected.accept(false)
                }
            }).disposed(by: disposeBag)
        
        registrationButton.isSelected
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: false)
            .emit(onNext: { [weak self] isSelect in
                guard let self = self else {
                    return
                }
                if isSelect {
                    expirationButton.isSelected.accept(false)
                    nameButton.isSelected.accept(false)
                }
            }).disposed(by: disposeBag)
        
        nameButton.isSelected
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: false)
            .emit(onNext: { [weak self] isSelect in
                guard let self = self else {
                    return
                }
                if isSelect {
                    expirationButton.isSelected.accept(false)
                    registrationButton.isSelected.accept(false)
                }
            }).disposed(by: disposeBag)
    }
}
