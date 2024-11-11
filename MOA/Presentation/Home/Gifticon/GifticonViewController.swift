//
//  GifticonViewController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit

final class GifticonViewController: BaseViewController {
    
    private lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView()
        StoreCategory.allCases.forEach {
            let button = CategoryButton(frame: .zero, category: $0)
            button.titleLabel?.font = UIFont(name: pretendard_medium, size: 14.0)
            button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 6.0, right: 12.0)
            button.snp.makeConstraints { $0.height.equalTo(32) }
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapSortButton), for: .touchUpInside)
        button.setTitle(sortType.rawValue, for: .normal)
        button.setTitleColor(.grey80, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_medium, size: 13.0)
        button.semanticContentAttribute = .forceRightToLeft
        button.setImage(UIImage(named: DOWN_ARROW)?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private lazy var gifticonCollectionView: UICollectionView = {
        let width = getWidthByDivision(division: 2, exclude: 20 + 16 + 20) // left + middle + right
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Double(width), height: Double(width) * 234 / 159.5)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 24.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GifticonCell.self, forCellWithReuseIdentifier: GifticonCell.identifier)
        return collectionView
    }()
    
    private var sortType: SortType = .EXPIRATION_DATE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupNavigationBar()
        setupLayout()
        setupData()
        subscribe()
    }
}

// MARK: setup
private extension GifticonViewController {
    func setupNavigationBar() {
        let label = UILabel()
        label.text = GIFTICON_MENU_TITLE
        label.font = UIFont(name: pretendard_bold, size: 22)
        label.textColor = .grey90
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    func setupLayout() {
        [categoryStackView, sortButton, gifticonCollectionView].forEach {
            view.addSubview($0)
        }
        
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.left.equalToSuperview().inset(20)
        }
        
        sortButton.snp.makeConstraints {
            $0.centerY.equalTo(categoryStackView)
            $0.right.equalToSuperview().inset(20)
        }
        
        gifticonCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupData() {
        if let button = categoryStackView.arrangedSubviews.first as? CategoryButton {
            button.isClicked.accept(true)
        }
    }
    
    func subscribe() {
        categoryStackView.arrangedSubviews.forEach {
            if let button = $0 as? CategoryButton {
                button.rx.tap
                    .subscribe(onNext: { [weak self] in
                        button.isClicked.accept(true)
                        self?.categoryStackView.arrangedSubviews
                            .filter { $0 != button }
                            .map { $0 as? CategoryButton }
                            .forEach { $0?.isClicked.accept(false) }
                    }).disposed(by: disposeBag)
            }
        }
    }
}

// MARK: objc function
extension GifticonViewController {
    @objc func tapSortButton() {
        let bottomSheetVC = BottomSheetViewController(sheetType: .Sort, sortType: sortType)
        bottomSheetVC.delegate = self
        self.present(bottomSheetVC, animated: true)
    }
}

// MARK: BottomSheetDelegate
extension GifticonViewController: BottomSheetDelegate {
    func selectSortType(type: SortType) {
        MOALogger.logd(type.rawValue)
        sortType = type
        sortButton.setTitle(type.rawValue, for: .normal)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension GifticonViewController: UICollectionViewDelegateFlowLayout {
    
}

// MARK:
extension GifticonViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifticonCell.identifier, for: indexPath) as? GifticonCell else {
            return UICollectionViewCell()
        }
        
        cell.setData(
            dday: 3,
            imageURL: "https://cdn.najunews.kr/news/photo/202311/222522_16128_3436.jpg",
            store: "스타벅스",
            title: "스타벅스 쿠폰 써야해",
            date: "2024-12-08"
        )
        
        return cell
    }
}
