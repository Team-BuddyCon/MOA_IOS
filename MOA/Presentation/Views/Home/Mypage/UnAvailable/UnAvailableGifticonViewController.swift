//
//  UnAvailableGifticonViewController.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

protocol UnAvailableGifticonViewControllerDelegate: AnyObject {
    func navigateToGifticonDetail(gifticonId: String)
}

final class UnAvailableGifticonViewController: BaseViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grey90
        label.font = UIFont(name: pretendard_bold, size: 18.0)
        return label
    }()
    
    fileprivate lazy var gifticonCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 24.0
        layout.minimumInteritemSpacing = 16.0
        layout.sectionInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let width = Double(UIScreen.getWidthByDivision(division: 2, exclude: 56))
        layout.itemSize = CGSize(width: width, height: width * 234 / 159.5)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(GifticonCell.self, forCellWithReuseIdentifier: GifticonCell.identifier)
        collectionView.register(GifticonSkeletonCell.self, forCellWithReuseIdentifier: GifticonSkeletonCell.identifier)
        return collectionView
    }()
    
    
    let viewWillAppear = PublishRelay<Void>()
    let tapUsedGifticon = PublishRelay<String>()
    
    let viewModel = UnAvailableGifticonViewModel(gifticonService: GifticonService.shared)
    
    weak var delegate: UnAvailableGifticonViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOALogger.logd()
        viewWillAppear.accept(())
    }
}

private extension UnAvailableGifticonViewController {
    func setupLayout() {
        setupTopBarWithBackButton(title: UNAVAILABLE_GIFTIFON_TITLE)
        
        view.addSubview(titleLabel)
        view.addSubview(gifticonCollectionView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20.0)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16.0)
        }
        
        gifticonCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bind() {
        let input = UnAvailableGifticonViewModel.Input (
            viewWillAppear: viewWillAppear,
            tapUsedGifticon: tapUsedGifticon
        )
        
        let output = viewModel.transform(input: input)
        
        output.showUsedGifticons
            .drive(gifticonCollectionView.rx.items) { collectionView, row, gifticon in
                if gifticon.gifticonId.isEmpty {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: GifticonSkeletonCell.identifier,
                        for: IndexPath(row: row, section: 0)
                    ) as? GifticonSkeletonCell else {
                        return UICollectionViewCell()
                    }
                    return cell
                }
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifticonCell.identifier, for: IndexPath(row: row, section: 0)) as? GifticonCell else {
                    return UICollectionViewCell()
                }
                
                cell.gifticon = gifticon
                return cell
            }.disposed(by: disposeBag)
        
        output.showUsedGifticons
            .drive(self.rx.bindToUsedGifticon)
            .disposed(by: disposeBag)
        
        output.showGifticonDetail
            .emit(to: self.rx.showGifticonDetail)
            .disposed(by: disposeBag)
        
        gifticonCollectionView.rx.modelSelected(GifticonModel.self)
            .subscribe(onNext: { [unowned self] gifticon in
                self.tapUsedGifticon.accept(gifticon.gifticonId)
            }).disposed(by: disposeBag)
    }
}

extension Reactive where Base: UnAvailableGifticonViewController {
    var bindToUsedGifticon: Binder<[GifticonModel]> {
        return Binder<[GifticonModel]>(self.base) { viewController, gifticons in
            viewController.titleLabel.text = String(format: UNAVAILABLE_GIFTICON_COUNT_TITLE_FORMAT, gifticons.count)
            viewController.gifticonCollectionView.reloadData()
            viewController.gifticonCollectionView.layoutIfNeeded()
        }
    }
    
    var showGifticonDetail: Binder<String> {
        return Binder<String>(self.base) { viewController, gifticonId in
            viewController.delegate?.navigateToGifticonDetail(gifticonId: gifticonId)
        }
    }
    
}
