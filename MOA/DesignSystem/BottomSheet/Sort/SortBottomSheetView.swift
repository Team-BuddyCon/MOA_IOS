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
    private let _sortType: PublishRelay<SortType> = PublishRelay()
    let sortType: Signal<SortType>
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        return view
    }()
    
    private lazy var expirationButton: SortButton = {
        let button = SortButton(type: .EXPIRE_DATE)
        return button
    }()
    
    private lazy var registrationButton: SortButton = {
        let button = SortButton(type: .CREATED_AT)
        return button
    }()
    
    private lazy var nameButton: SortButton = {
        let button = SortButton(type: .NAME)
        return button
    }()
    
    init(type: SortType) {
        sortType = _sortType.asSignal(onErrorJustReturn: type)
        super.init(frame: .zero)
        setupLayout()
        setupData(type: type)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        let width = Int(UIScreen.main.bounds.width)
        let heith = BottomSheetType.Sort.rawValue
        frame = CGRect(x: 0, y: 0, width: width, height: heith)
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
    
    func bind() {
        let sortButtons = subviews
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
                            _sortType.accept(button.type)
                            sortButtons
                                .filter { $0 != button }
                                .forEach { $0?.isSelected.accept(false) }
                        }
                    }).disposed(by: disposeBag)
                }
            }
    }
    
    func setupData(type: SortType) {
        switch type {
        case .EXPIRE_DATE:
            expirationButton.isSelected.accept(true)
        case .CREATED_AT:
            registrationButton.isSelected.accept(true)
        case .NAME:
            nameButton.isSelected.accept(true)
        }
    }
}
