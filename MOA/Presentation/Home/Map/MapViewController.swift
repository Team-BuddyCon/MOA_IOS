//
//  MapViewController.swift
//  MOA
//
//  Created by 오원석 on 11/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import KakaoMapsSDK

final class MapViewController: BaseViewController {
    
    let storeTypes: [StoreType] = StoreType.allCases
    private lazy var storeTypeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StoreTypeTextCell.self, forCellWithReuseIdentifier: StoreTypeTextCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var kmAuth: Bool = false
    var mapManager: KakaoMapManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupMap()
        setupLayout()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOALogger.logd()
        mapManager?.addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        if mapManager?.isEngineActive == false {
            mapManager?.activeEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapManager?.kmAuth = false
        mapManager?.removeObserver()
        mapManager?.pauseEngine()
        mapManager?.resetEngine()
        super.viewWillDisappear(animated)
        MOALogger.logd()
    }
}

private extension MapViewController {
    func setupMap() {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height) - (Int(navigationController?.navigationBar.frame.height ?? 0) + 16)
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        mapManager = KakaoMapManager.getInstance(rect: rect)
        mapManager?.prepareEngine()
    }
    
    func setupLayout() {
        guard let kmContrainer = mapManager?.container else { return }
        [
            storeTypeCollectionView,
            kmContrainer
        ].forEach {
            view.addSubview($0)
        }
        
        storeTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.left.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        kmContrainer.snp.makeConstraints {
            $0.top.equalTo(storeTypeCollectionView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupData() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        storeTypeCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreTypeTextCell.identifier, for: indexPath) as? StoreTypeTextCell else {
            return UICollectionViewCell()
        }
        
        cell.storeType = storeTypes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storeType = storeTypes[indexPath.row].rawValue
        let font = UIFont(name: pretendard_medium, size: 14.0)
        let textSize = storeType.size(withAttributes: [.font: font as Any])
        return CGSize(width: textSize.width + 24.0, height: 32.0)
    }
}
