//
//  WalkThroughViewController.swift
//  MOA
//
//  Created by 오원석 on 8/20/24.
//

import UIKit
import SnapKit

private struct WalkThroughPageItem {
    let imgRes: String
    let title: String
    let description: String
}

final class WalkThroughViewController: UIViewController {
    
    private let pageItems: [WalkThroughPageItem] = [
        WalkThroughPageItem(
            imgRes: WALKTHROUGH_BANNER1_IMGRES,
            title: WALKTHROUGH_BANNER1_TITLE,
            description: WALKTHROUGH_BANNER1_DESCRIPTION
        ),
        WalkThroughPageItem(
            imgRes: WALKTHROUGH_BANNER2_IMGRES,
            title: WALKTHROUGH_BANNER2_TITLE,
            description: WALKTHROUGH_BANNER2_DESCRIPTION
        )
    ]
    
    var currentPage: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                pageIndicator.index = currentPage
                pagerCollectionView.scrollToItem(at: IndexPath(row: self.currentPage, section: 0), at: .centeredHorizontally, animated: false)
            }
            
            skipButton.isHidden = currentPage == pageItems.endIndex-1
            nextButton.isHidden = currentPage == pageItems.endIndex-1
            startButton.isHidden = currentPage != pageItems.endIndex-1
        }
    }
    
    private lazy var pagerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            WalkThroughPageViewCell.self,
            forCellWithReuseIdentifier: WalkThroughPageViewCell.idendifier
        )
        return collectionView
    }()
    
    private lazy var pageIndicator: WalkThroughPageIndicator = {
        let indicator = WalkThroughPageIndicator(size: pageItems.count)
        return indicator
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle(WALKTHROUGH_SKIP, for: .normal)
        button.setTitleColor(.grey60, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_medium, size: 15.0)
        button.addTarget(self, action: #selector(tapSkipButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(WALKTHROUGH_NEXT, for: .normal)
        button.setTitleColor(.pink100, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_medium, size: 15.0)
        button.addTarget(self, action: #selector(tapNextButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var startButton: CommonButton = {
        let button = CommonButton(title: LETS_START, fontSize: 16.0)
        button.isHidden = true
        button.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
}

private extension WalkThroughViewController {
    func setupAppearance() {
        view.backgroundColor = .white
        
        [pagerCollectionView, pageIndicator, skipButton, nextButton, startButton].forEach {
            view.addSubview($0)
        }
        
        pagerCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(pagerCollectionView.snp.width).multipliedBy(431.0/375.0)
            $0.centerY.equalToSuperview().offset(-(14.5))
        }
        
        pageIndicator.snp.makeConstraints {
            $0.bottom.equalTo(skipButton.snp.top).offset(-51)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(8)
        }
        
        skipButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(45.5)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(45.5)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(34)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
    }
}

extension WalkThroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = pageItems[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WalkThroughPageViewCell.idendifier,
            for: indexPath
        ) as? WalkThroughPageViewCell {
            cell.imageView.image = UIImage(named: item.imgRes)
            cell.titleLabel.text = item.title
            cell.descLabel.setTextWithLineHeight(
                text: item.description,
                font: pretendard_medium, 
                size: 14.0,
                lineSpacing: 19.6
            )
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension WalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: width * 431 / 375.0)
    }

    /**
     스크롤 뷰 드래그 종료 시 page 결정
     - -halfwith .. halfwidth -> 0 page
     - halfwidth .. width + halfwidth -> 1 page
     - ...
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let width = UIScreen.main.bounds.width
        currentPage = Int(round(scrollView.contentOffset.x / width))
    }
}

private extension WalkThroughViewController {
    @objc func tapSkipButton() {
        print("tapSkipButton")
    }
    
    @objc func tapNextButton() {
        
    }
    
    @objc func tapStartButton() {
        
    }
}
