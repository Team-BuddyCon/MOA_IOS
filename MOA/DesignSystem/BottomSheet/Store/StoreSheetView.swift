//
//  StoreSheetView.swift
//  MOA
//
//  Created by 오원석 on 11/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class StoreSheetView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.text = STORE
        label.textColor = .grey90
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: CLOSE_BUTTON), for: .normal)
        return button
    }()
    
    private let storeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 21
        
        let itemWidth = getWidthByDivision(division: 4, exclude: 103)
        layout.itemSize = CGSize(width: itemWidth, height: 102)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20)
            
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StoreTypeCell.self, forCellWithReuseIdentifier: StoreTypeCell.identifier)
        return collectionView
    }()
    
    private let storeTypes = BehaviorRelay(value: Array(StoreType.allCases.dropFirst()))

    init() {
        super.init(frame: .zero)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let width = Int(UIScreen.main.bounds.width)
        let height = BottomSheetType.Store.rawValue
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.cornerRadius = 16
        backgroundColor = .white
        
        [titleLabel, closeButton, storeCollectionView].forEach {
            addSubview($0)
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
    }
    
    private func bind() {
        storeTypes.bind(to: storeCollectionView.rx.items(cellIdentifier: StoreTypeCell.identifier, cellType: StoreTypeCell.self)) { row, storeType, cell in
            cell.setData(storeType: storeType)
        }.disposed(by: disposeBag)
    }
}
