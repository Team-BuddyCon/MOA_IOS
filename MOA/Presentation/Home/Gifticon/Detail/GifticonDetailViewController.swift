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
import KakaoMapsSDK

final class GifticonDetailViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let useButton: CommonButton = {
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
        imageView.backgroundColor = .black.withAlphaComponent(0.5)
        return imageView
    }()
    
    let imageDimView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: USED_GIFTICON)
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .black.withAlphaComponent(0.5)
        imageView.isHidden = true
        return imageView
    }()
    
    let ddayButton: DDayButton = {
        let button = DDayButton(fontSize: 12.0)
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
    
    let kmZoomInButton: UIButton = {
        let button = UIButton()
        button.setTitle(GIFTICON_DETAIL_MAP_ZOOM_IN_BUTTON_TITLE, for: .normal)
        button.setTitleColor(.pink100, for: .normal)
        button.titleLabel?.font = UIFont(name: pretendard_bold, size: 12.0)
        button.backgroundColor = .pink50
        button.layer.cornerRadius = 18.5
        return button
    }()
    
    lazy var mapDimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var mapGuideLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grey70
        label.setRangeFontColor(
            text: MAP_PERMISSION_GUIDE_MESSAGE,
            startIndex: 0,
            endIndex: 8,
            color: .pink100
        )
        label.font = UIFont(name: pretendard_medium, size: 12.0)
        return label
    }()
    
    lazy var mapGuideToastView: UIView = {
        let view = UIView()
        view.addSubview(mapGuideLabel)
        view.layer.cornerRadius = 21
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.applyShadow(
            color: UIColor.black.withAlphaComponent(0.1).cgColor,
            opacity: 1,
            blur: 10,
            x: 0.0,
            y: 2.0
        )
        
        mapGuideLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSetting))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    var mapManager: KakaoMapManager?
    
    let gifticonDetailViewModel = GifticonDetailViewModel(
        gifticonService: GifticonService.shared,
        kakaoService: KakaoService.shared
    )
    
    let gifticonId: String
    
    var isActive: Bool = true
    
    init(gifticonId: String) {
        self.gifticonId = gifticonId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupMap()
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOALogger.logd()
        mapManager?.addObserver()
        gifticonDetailViewModel.fetchGifticon(gifticonId: gifticonId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        if isActive {
            if mapManager?.isEngineActive == false {
                mapManager?.activateEngine()
            }
            gifticonDetailViewModel.searchPlaceByKeyword()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapManager?.kmAuth = false
        mapManager?.removeObserver()
        mapManager?.pauseEngine()
        super.viewWillDisappear(animated)
        MOALogger.logd()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if gifticonDetailViewModel.gifticon.used {
            NotificationManager.shared.remove(
                gifticonDetailViewModel.gifticon.expireDate,
                name: gifticonDetailViewModel.gifticon.name
            )
        } else {
            let date = gifticonDetailViewModel.gifticon.expireDate.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT)
            let notificationDate = UserPreferences.getNotificationDday().getNotificationDate(target: date)
            guard let notificationDate = notificationDate else { return }
            if notificationDate <= Date() { return }
            
            NotificationManager.shared.register(
                gifticonDetailViewModel.gifticon.expireDate,
                date: notificationDate,
                name: gifticonDetailViewModel.gifticon.name
            )
        }
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
        
        guard let kmContainer = mapManager?.container else { return }
        
        [
            imageView,
            imageDimView,
            ddayButton,
            imageZoomInButton,
            titleLabel,
            expireDateInfoView,
            storeInfoView,
            memoInfoView,
            kmContainer,
            kmZoomInButton,
            mapDimView,
            mapGuideToastView
        ].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(imageView.snp.width).multipliedBy(328 / 335.0)
        }
        
        imageDimView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(imageView.snp.width).multipliedBy(328 / 335.0)
        }
        
        ddayButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.top).inset(16)
            $0.leading.equalTo(imageView.snp.leading).inset(16)
            $0.height.equalTo(26)
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
        }
        
        kmContainer.snp.remakeConstraints {
            $0.top.equalTo(memoInfoView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(kmContainer.snp.width).multipliedBy(166 / 335.0)
        }
        
        kmZoomInButton.snp.makeConstraints {
            $0.bottom.equalTo(kmContainer.snp.bottom).inset(12)
            $0.trailing.equalTo(kmContainer.snp.trailing).inset(12)
            $0.width.equalTo(109)
            $0.height.equalTo(37)
        }
        
        mapDimView.snp.makeConstraints {
            $0.edges.equalTo(kmContainer)
        }
        
        mapGuideToastView.snp.makeConstraints {
            $0.center.equalTo(mapDimView)
            $0.width.equalTo(242)
            $0.height.equalTo(42)
        }
    }
    
    func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackBarButton)
        )
        
        backButtonItem.tintColor = .grey90
        navigationItem.leftBarButtonItem = backButtonItem
        
        let titleLabel = UILabel()
        titleLabel.text = GIFTICON_MENU_TITLE
        titleLabel.font = UIFont(name: pretendard_bold, size: 15.0)
        titleLabel.textColor = .grey90
        navigationItem.titleView = titleLabel
        
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 15.0)
        label.textColor = .pink100
        label.text = EDIT
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEditButton)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    func setupMap() {
        let width = Int(UIScreen.main.bounds.width) - 40
        let height = Int(Double(width) * 166.0 / 335.0)
        mapManager = KakaoMapManager(rect: CGRect(x: 0, y: 0, width: width, height: height))
        mapManager?.delegate = mapManager
        mapManager?.prepareEngine()
        
        guard let container = mapManager?.container else { return }
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true
    }
    
    func bind() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        useButton.rx.tap
            .bind(to: self.rx.tapUse)
            .disposed(by: disposeBag)
        
        imageZoomInButton.rx.tap
            .bind(to: self.rx.tapZoomInImage)
            .disposed(by: disposeBag)
        
        gifticonDetailViewModel.gifticonRelay
            .bind(to: self.rx.bindToGifticon)
            .disposed(by: disposeBag)
        
        kmZoomInButton.rx.tap
            .bind(to: self.rx.tapZoomInMap)
            .disposed(by: disposeBag)
        
        gifticonDetailViewModel.searchPlaceRelay
            .bind(to: self.rx.bindSearchPlaces)
            .disposed(by: disposeBag)
        
        LocationManager.shared.isGranted
            .bind(to: self.rx.bindToLocationPermission)
            .disposed(by: disposeBag)
    }
}

// TODO: tapZoomInImage 와 같은 공통 extension은 ImageView 확장하여 함수로 정의
extension Reactive where Base: GifticonDetailViewController {
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
            viewController.gifticonDetailViewModel.updateGifticonUsed(gifticonId: viewController.gifticonId)
        }
    }
    
    var tapZoomInMap: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            MOALogger.logd()
            let gifticonMapVC = GifticonDetailMapViewController(
                searchPlaces: viewController.gifticonDetailViewModel.searchPlaceRelay.value,
                storeType: viewController.gifticonDetailViewModel.gifticon.gifticonStore
            )
            viewController.navigationController?.pushViewController(gifticonMapVC, animated: true)
        }
    }
    
    var bindToGifticon: Binder<GifticonModel> {
        return Binder<GifticonModel>(self.base) { (viewController: GifticonDetailViewController, gifticon) in
            ImageLoadManager.shared.load(
                url: gifticon.imageUrl,
                identifier: gifticon.gifticonId,
                expireDate: gifticon.expireDate
            )
                .observe(on: MainScheduler())
                .subscribe(onNext: { image in
                    if let image = image {
                        viewController.imageView.image = image
                    }
                }).disposed(by: viewController.disposeBag)
            
            let dday = gifticon.expireDate.toDday()
            viewController.ddayButton.dday = dday
            
            viewController.titleLabel.text = gifticon.name
            viewController.expireDateInfoView.info = gifticon.expireDate
            viewController.storeInfoView.info = gifticon.gifticonStore.rawValue
            viewController.memoInfoView.info = gifticon.memo
            
            if !gifticon.used && !gifticon.imageUrl.isEmpty && dday < 0 {
                viewController.showAlertModal(
                    title: GIFTICON_REGISTER_EXPIRE_MODAL_TITLE,
                    subTitle: GIFTICON_REGISTER_EXPIRE_MODAL_SUBTITLE,
                    confirmText: CONFIRM
                )
            }
            
            viewController.ddayButton.isHidden = gifticon.used
            viewController.imageZoomInButton.isHidden = gifticon.used
            viewController.imageDimView.isHidden = !gifticon.used
            viewController.useButton.status.accept(gifticon.used ? .used : .active)
            viewController.useButton.setTitle(gifticon.used ? GIFTICON_USED_BUTTON_TITLE : GIFTICON_USE_BUTTON_TITLE, for: .normal)
            
            let storeType = viewController.gifticonDetailViewModel.gifticon.gifticonStore
            if storeType == .OTHERS {
                viewController.mapDimView.isHidden = false
                viewController.mapGuideToastView.isHidden = false
                viewController.mapGuideLabel.setRangeFontColor(
                    text: MAP_NOT_PROVIDED_GUIDE_MESSAGE,
                    startIndex: 13,
                    endIndex: 18,
                    color: .pink100
                )
                
                viewController.mapGuideToastView.snp.remakeConstraints {
                    $0.center.equalTo(viewController.mapDimView)
                    $0.width.equalTo(283)
                    $0.height.equalTo(42)
                }
            } else {
                viewController.mapDimView.isHidden = true
                viewController.mapGuideToastView.isHidden = true
                viewController.mapGuideLabel.setRangeFontColor(
                    text: MAP_PERMISSION_GUIDE_MESSAGE,
                    startIndex: 0,
                    endIndex: 8,
                    color: .pink100
                )
                
                viewController.mapGuideToastView.snp.remakeConstraints {
                    $0.center.equalTo(viewController.mapDimView)
                    $0.width.equalTo(242)
                    $0.height.equalTo(42)
                }
            }
        }
    }
    
    var bindSearchPlaces: Binder<[SearchPlace]> {
        return Binder<[SearchPlace]>(self.base) { (viewController: GifticonDetailViewController, searchPlaces) in
            if searchPlaces.count > 0 {
                let storeType = viewController.gifticonDetailViewModel.gifticon.gifticonStore
                viewController.mapManager?.createPois(
                    searchPlaces: searchPlaces,
                    storeType: storeType,
                    scale: 0.3,
                    upScale: 0.3
                )
            } else {
                viewController.mapManager?.removePois()
            }
        }
    }
    
    var bindToLocationPermission: Binder<Bool> {
        return Binder<Bool>(self.base) { viewController, isGranted in
            MOALogger.logd()
            let storeType = viewController.gifticonDetailViewModel.gifticon.gifticonStore
            viewController.mapDimView.isHidden = storeType != .OTHERS && isGranted
            viewController.mapGuideToastView.isHidden = storeType != .OTHERS && isGranted
            
            if storeType != .OTHERS && isGranted && viewController.mapManager?.isEngineActive == true {
                viewController.gifticonDetailViewModel.searchPlaceByKeyword()
            } else {
                viewController.mapManager?.removePois()
            }
            viewController.mapManager?.updateLocation()
        }
    }
}

extension GifticonDetailViewController {
    @objc func openSetting() {
        MOALogger.logd()
        guard gifticonDetailViewModel.gifticon.gifticonStore != .OTHERS else { return }
        
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func tapBackBarButton() {
        navigatePopUpTo(type: HomeTabBarController.self)
    }
    
    @objc func tapEditButton() {
        MOALogger.logd()
        let editVC = GifticonEditViewController(
            gifticon: gifticonDetailViewModel.gifticon,
            gifticonImage: imageView.image
        )
        navigationController?.pushViewController(editVC, animated: false)
    }
    
    @objc func didBecomeActive() {
        MOALogger.logd()
        isActive = true
        
        if mapManager?.isEngineActive == false {
            mapManager?.activateEngine()
            gifticonDetailViewModel.searchPlaceByKeyword()
        }
    }
    
    @objc func willResignActive() {
        MOALogger.logd()
        isActive = false
    }
}
