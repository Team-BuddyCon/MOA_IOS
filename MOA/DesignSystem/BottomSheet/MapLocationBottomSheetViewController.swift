//
//  MapLocationBottomSheetVIewController.swift
//  MOA
//
//  Created by 오원석 on 6/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class MapLocationBottomSheetViewController: BottomSheetViewController {
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey40
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.textColor = .grey90
        return label
    }()
    
    private let distInfoLabel: UILabel = {
        let label = UILabel()
        label.text = MAP_DISTANCE
        label.font = UIFont(name: pretendard_bold, size: 12.0)
        label.textColor = .grey90
        return label
    }()
    
    private let distLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .grey90
        return label
    }()
    
    private let findPathButton: CommonButton = {
        let button = CommonButton(title: MAP_FIND_PATH)
        return button
    }()
    
    private let addressCopyButton: CommonButton = {
        let button = CommonButton(status: .used, title: MAP_ADDRESS_COPY)
        return button
    }()
    
    lazy var infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var naverLinkButton: MapLinkButton = {
        let button = MapLinkButton(type: .Naver, hasLine: true)
        return button
    }()
    
    private lazy var kakaoLinkButton: MapLinkButton = {
        let button = MapLinkButton(type: .Kakao, hasLine: true)
        return button
    }()
    
    private lazy var googleLinkButton: MapLinkButton = {
        let button = MapLinkButton(type: .Google)
        return button
    }()
    
    lazy var linkView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var searchPlace: SearchPlace? {
        didSet {
            guard let searchPlace = searchPlace else { return }
            titleLabel.text = searchPlace.place_name
            distLabel.text = String(format: MAP_DISTANCE_FORMAT, (Double(searchPlace.distance) ?? 0.0) / 1000.0)
        }
    }
    
    override var sheetType: BottomSheetType {
        didSet {
            switch sheetType {
            case .MapStore(let place):
                infoView.isHidden = false
                linkView.isHidden = true
            case .MapDeepLink:
                infoView.isHidden = true
                linkView.isHidden = false
            default:
                fatalError()
            }
            
            contentView.snp.remakeConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(self.sheetType.height)
                $0.bottom.equalToSuperview()
            }
        }
    }
    
    override init(sheetType: BottomSheetType) {
        switch sheetType {
        case .MapStore(let place):
            super.init(sheetType: sheetType)
        default:
            fatalError()
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        [
            titleLabel,
            distInfoLabel,
            distLabel,
            findPathButton,
            addressCopyButton
        ].forEach {
            infoView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        distInfoLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
        }
        
        distLabel.snp.makeConstraints {
            $0.centerY.equalTo(distInfoLabel.snp.centerY)
            $0.leading.equalTo(distInfoLabel.snp.trailing).offset(16)
        }
        
        let buttonW = UIScreen.getWidthByDivision(division: 2, exclude: 48)
        findPathButton.snp.makeConstraints {
            $0.top.equalTo(distInfoLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(buttonW)
        }
        
        addressCopyButton.snp.makeConstraints {
            $0.top.equalTo(distInfoLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(buttonW)
        }
        
        [
            naverLinkButton,
            kakaoLinkButton,
            googleLinkButton
        ].forEach {
            linkView.addSubview($0)
        }
        
        naverLinkButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        kakaoLinkButton.snp.makeConstraints {
            $0.top.equalTo(naverLinkButton.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        googleLinkButton.snp.makeConstraints {
            $0.top.equalTo(kakaoLinkButton.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        [
            lineView,
            infoView,
            linkView
        ].forEach {
            contentView.addSubview($0)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(4)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        
        linkView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    override func bind() {
        super.bind()
        
        addressCopyButton.rx.tap
            .bind(to: self.rx.bindAddressCopy)
            .disposed(by: disposeBag)
        
        findPathButton.rx.tap
            .bind(to: self.rx.bindFindPath)
            .disposed(by: disposeBag)
        
        naverLinkButton.tap.rx.event
            .bind(to: self.rx.bindNaverLink)
            .disposed(by: disposeBag)
        
        kakaoLinkButton.tap.rx.event
            .bind(to: self.rx.bindKakaoLink)
            .disposed(by: disposeBag)
        
        googleLinkButton.tap.rx.event
            .bind(to: self.rx.bindGoogleLink)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: MapLocationBottomSheetViewController {
    var bindAddressCopy: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            UIPasteboard.general.string = viewController.searchPlace?.address_name
            Toast.shared.show(message: MAP_ADDRESS_COPY_TOAST_MESSAGE, down: false)
        }
    }
    
    var bindFindPath: Binder<Void> {
        return Binder<Void>(self.base) { viewController, _ in
            viewController.sheetType = .MapDeepLink
        }
    }
    
    var bindNaverLink: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, gesture in
            MOALogger.logd()
            guard let slat = LocationManager.shared.latitude else { return }
            guard let slng = LocationManager.shared.longitude else { return }
            guard let sname = LocationManager.shared.address else { return }
            guard let dlat = viewController.searchPlace?.y else { return }
            guard let dlng = viewController.searchPlace?.x else { return }
            guard let dname = viewController.searchPlace?.place_name else { return }
            
            let appStoreURL = URL(string: "http://apps.apple.com/app/id311867728")!
            let urlString = "nmap://route/walk?slat=\(slat)&slng=\(slng)&sname=\(sname)&dlat=\(dlat)&dlng=\(dlng)&dname=\(dname)&appname=MOA"
            if urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil {
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
        }
    }
    
    var bindKakaoLink: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, gesture in
            MOALogger.logd()
            guard let slat = LocationManager.shared.latitude else { return }
            guard let slng = LocationManager.shared.longitude else { return }
            guard let dlat = viewController.searchPlace?.y else { return }
            guard let dlng = viewController.searchPlace?.x else { return }
            
            let sp = "\(slat),\(slng)"
            let ep = "\(dlat),\(dlng)"
            
            let appStoreURL = URL(string: "http://apps.apple.com/app/id304608425")!
            let urlString = "kakaomap://route?sp=\(sp)&ep=\(ep)&by=FOOT"
            if urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil {
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
        }
    }
    
    var bindGoogleLink: Binder<UITapGestureRecognizer> {
        return Binder<UITapGestureRecognizer>(self.base) { viewController, gesture in
            MOALogger.logd()
            guard let slat = LocationManager.shared.latitude else { return }
            guard let slng = LocationManager.shared.longitude else { return }
            guard let sname = LocationManager.shared.address else { return }
            guard let dlat = Double(viewController.searchPlace?.y ?? "0.0") else { return }
            guard let dlng = Double(viewController.searchPlace?.x ?? "0.0") else { return }
            guard let dname = viewController.searchPlace?.place_name else { return }
            
            let saddr = "\(slat),\(slng)"
            let daddr = "\(dlat),\(dlng)(\(dname))"
            
            let appStoreURL = URL(string: "http://apps.apple.com/app/id585027354")!
            let urlString = "comgooglemaps://?saddr=\(saddr)&daddr=\(daddr)&directionsmode=walking"
            if urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil {
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
        }
    }
}
