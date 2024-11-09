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

enum SortType: String {
    case ExpirationPeriod = "유효기간순"
    case Registration = "등록순"
    case Name = "이름순"
}

final class SortBottomSheetView: UIView {
    private let _type = BehaviorRelay(value: SortType.ExpirationPeriod)
    let type: Driver<SortType>
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        return view
    }()
    
    private lazy var expirationButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.ExpirationPeriod.rawValue, for: .normal)
        button.setTitleColor(.grey60, for: .normal)
        return button
    }()
    
    private lazy var registrationButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.Registration.rawValue, for: .normal)
        button.setTitleColor(.grey60, for: .normal)
        return button
    }()
    
    private lazy var nameButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.Name.rawValue, for: .normal)
        button.setTitleColor(.grey60, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        type = _type.asDriver(onErrorJustReturn: .ExpirationPeriod)
        super.init(frame: frame)
        setupLayout()
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
            $0.bottom.equalToSuperview().inset(42)
        }
    }
}
