//
//  GifticonDetailViewController.swift
//  MOA
//
//  Created by 오원석 on 12/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class GifticonDetailViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let useButton: CommonButton = {
        let button = CommonButton(
            status: .active,
            title: GIFTICON_USE_BUTTON_TITLE
        )
        return button
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let ddayButton: DDayButton = {
        let button = DDayButton()
        return button
    }()
    
    let imageZoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ZOOM_IN_BUTTON), for: .normal)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: pretendard_bold, size: 22.0)
        label.textColor = .grey90
        return label
    }()
    
    let expireDateInfoView: DetailInfoView = {
        let view = DetailInfoView(title: GIFTICON_DETAIL_EXPIRE_DATE_TITLE)
        return view
    }()
    
    let storeInfoView: DetailInfoView = {
        let view = DetailInfoView(title: GIFTICON_DETAIL_STORE_TITLE)
        return view
    }()
    
    let memoInfoView: DetailInfoView = {
        let view = DetailInfoView(title: GIFTICON_DETAIL_MEMO_TITLE)
        return view
    }()
    
    let viewModel = GifticonDetailViewModel(gifticonService: GifticonService.shared)
    private let gifticonId: Int
    
    init(gifticonId: Int) {
        self.gifticonId = gifticonId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
}

private extension GifticonDetailViewController {
    func setupLayout() {
        setupNavigationBar()
        
        [scrollView, useButton].forEach {
            view.addSubview($0)
        }
        
        useButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(useButton.snp.top).offset(-16)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        [
            imageView,
            imageZoomInButton,
            titleLabel,
            expireDateInfoView,
            storeInfoView,
            memoInfoView
        ].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(imageView.snp.width).multipliedBy(328 / 335.0)
        }
        
        imageZoomInButton.snp.makeConstraints {
            $0.trailing.equalTo(imageView.snp.trailing).inset(16)
            $0.bottom.equalTo(imageView.snp.bottom).inset(16)
            $0.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        expireDateInfoView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        storeInfoView.snp.makeConstraints {
            $0.top.equalTo(expireDateInfoView.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        memoInfoView.snp.makeConstraints {
            $0.top.equalTo(storeInfoView.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupNavigationBar() {
        setupTopBarWithBackButton(title: GIFTICON_MENU_TITLE)
        
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .pink100
        label.text = EDIT
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEditButton)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    func fetchData() {
        viewModel.fetchDetail(gifticonId: gifticonId)
    }
    
    func bind() {
        useButton.rx.tap
            .bind(to: self.rx.tapUse)
            .disposed(by: disposeBag)
        
        imageZoomInButton.rx.tap
            .bind(to: self.rx.tapZoomInImage)
            .disposed(by: disposeBag)
        
        viewModel.detailGifticonRelay
            .bind(to: self.rx.bindGifticon)
            .disposed(by: disposeBag)
    }
}

// TODO: tapZoomInImage 와 같은 공통 extension은 ImageView 확장하여 함수로 정의
private extension Reactive where Base: GifticonDetailViewController {
    var tapZoomInImage: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            let fullImageVC = FullGifticonImageViewController(image: viewController.imageView.image)
            viewController.present(fullImageVC, animated: true)
        }
    }
    
    var tapUse: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
        }
    }
    
    var bindGifticon: Binder<DetailGifticon> {
        return Binder<DetailGifticon>(self.base) { viewController, detailGifticon in
            ImageLoadManager.shared.load(url: detailGifticon.imageUrl)
                .observe(on: MainScheduler())
                .subscribe(onNext: { data in
                    if let data = data {
                        viewController.imageView.image = UIImage(data: data)
                    }
                }).disposed(by: viewController.disposeBag)
            
            viewController.ddayButton.dday = detailGifticon.expireDate
                .toString(format: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT)
                .transformTimeformat(origin: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT, dest: AVAILABLE_GIFTICON_UI_TIME_FORMAT)
                .toDday()
            
            viewController.titleLabel.text = detailGifticon.name
            viewController.expireDateInfoView.info = detailGifticon.expireDate
                .toString(format: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT)
                .transformTimeformat(origin: AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT, dest: AVAILABLE_GIFTICON_UI_TIME_FORMAT)
            
            viewController.storeInfoView.info = detailGifticon.gifticonStore.rawValue
            viewController.memoInfoView.info = detailGifticon.memo
        }
    }
}

extension GifticonDetailViewController {
    @objc func tapEditButton() {
        MOALogger.logd()
        let editVC = GifticonEditViewController(
            detailGifticon: viewModel.detailGifticon,
            gifticonImage: imageView.image
        )
        navigationController?.pushViewController(editVC, animated: false)
    }
}
