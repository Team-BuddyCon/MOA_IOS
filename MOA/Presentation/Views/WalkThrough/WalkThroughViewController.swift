//
//  WalkThroughViewController.swift
//  MOA
//
//  Created by 오원석 on 8/20/24.
//

import UIKit
import SnapKit

protocol WalkThroughViewControllerDelegate: AnyObject {
    func navigateToLogin()
}

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
    
    var currentPage: Int = 0
    
    weak var delegate: WalkThroughViewControllerDelegate?
    
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
        MOALogger.logd()
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
            $0.height.equalTo(pagerCollectionView.snp.width).multipliedBy(689.0/375.0)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(pageIndicator.snp.top)
        }
        
        pageIndicator.snp.makeConstraints {
            $0.bottom.equalTo(skipButton.snp.top).offset(-51)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(8)
        }
        
        skipButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
    }
    
    func updateWalkThrough() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            pageIndicator.index = currentPage
            pagerCollectionView.scrollToItem(at: IndexPath(row: self.currentPage, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        skipButton.isHidden = currentPage == pageItems.endIndex-1
        nextButton.isHidden = currentPage == pageItems.endIndex-1
        startButton.isHidden = currentPage != pageItems.endIndex-1
    }
}

// MARK: UICollectionViewDataSource
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

// MARK: UICollectionViewDelegateFlowLayout
extension WalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: width * 689 / 375.0)
    }

    /**
     스크롤 뷰 드래그 종료 시 page 결정
     - -with/4 ...width/4 -> 0 page
     - fwidth .. width + halfwidth -> 1 page
     - ...
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let width = Int(UIScreen.main.bounds.width)
        let contentOffset = Int(scrollView.contentOffset.x)
        let currentOffset = currentPage * width
        let diff = contentOffset - currentOffset
        
        if diff < 0 {
            if abs(diff) > width / 30 {
                currentPage = currentPage - 1 < 0 ? 0 : currentPage - 1
            }
        } else {
            if diff > width / 30 {
                currentPage = currentPage + 1 > pageItems.endIndex - 1 ? pageItems.endIndex - 1 : currentPage + 1
            }
        }
        
        updateWalkThrough()
    }
}

// MARK: objc
private extension WalkThroughViewController {
    @objc func tapSkipButton() {
        MOALogger.logd()
        self.delegate?.navigateToLogin()
    }
    
    @objc func tapNextButton() {
        MOALogger.logd()
        currentPage += 1
        updateWalkThrough()
    }
    
    @objc func tapStartButton() {
        MOALogger.logd()
        self.delegate?.navigateToLogin()
    }
}
