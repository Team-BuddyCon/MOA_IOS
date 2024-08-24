//
//  WalkThroughViewController.swift
//  MOA
//
//  Created by 오원석 on 8/20/24.
//

import UIKit
import SnapKit

final class WalkThroughViewController: UIViewController {
    
    var currentPage: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                pagerCollectionView.scrollToItem(at: IndexPath(row: self.currentPage, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    private lazy var pagerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .blue
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        return collectionView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
}

private extension WalkThroughViewController {
    func setupAppearance() {
        view.backgroundColor = .white
        
        [pagerCollectionView, skipButton, nextButton].forEach {
            view.addSubview($0)
        }
        
        pagerCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(pagerCollectionView.snp.width).multipliedBy(431/335)
            $0.centerY.equalToSuperview().offset(-14)
        }
        
        skipButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(29)
        }
        
        nextButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(29)
        }
    }
}

extension WalkThroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath) as? UICollectionViewCell {
            cell.backgroundColor = indexPath.row == 0 ? .red : .black
            return cell
        }
        return UICollectionViewCell()
    }
}

extension WalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        return CGSize(width: width, height: width * 335 / 431)
    }

    // -halfwith .. halfwidth -> 0
    // halfwidth .. width + halfwidth -> 1
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let width = UIScreen.main.bounds.width - 40
        print("\(width) \(scrollView.contentOffset.x) \(scrollView.contentOffset.x / width)")
        currentPage = Int(round(scrollView.contentOffset.x / width))
    }
}

private extension WalkThroughViewController {
    @objc func tapSkipButton() {
        print("tapSkipButton")
    }
    
    @objc func tapNextButton() {
        print("tapNextButton")
    }
}
