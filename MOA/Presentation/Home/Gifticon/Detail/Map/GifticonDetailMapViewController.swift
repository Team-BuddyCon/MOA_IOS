//
//  GifticonDetailMapViewController.swift
//  MOA
//
//  Created by 오원석 on 12/29/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import KakaoMapsSDK

final class GifticonDetailMapViewController: BaseViewController, MapControllerDelegate {
    
    let kmContainer: KMViewContainer = {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        let container = KMViewContainer(frame: CGRect(x: 0, y: 0, width: width, height: height))
        return container
    }()
    
    let confirmButton: CommonButton = {
        let button = CommonButton(title: GIFTICON_DETAIL_MAP_CONFIRM_BUTTON_TITLE)
        return button
    }()
    
    var kmController: KMController? = nil
    private var kmAuth: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        setupMap()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MOALogger.logd()
        
        if kmController?.isEngineActive == false {
            kmController?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        kmAuth = false
        kmController?.pauseEngine()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        kmController?.resetEngine()
        super.viewDidDisappear(animated)
    }
    
    private func setupLayout() {
        setupTopBarWithBackButton(title: MAP_MENU_TITLE)
        
        view.addSubview(kmContainer)
        view.addSubview(confirmButton)
        
        kmContainer.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(11.5)
            $0.height.equalTo(54)
        }
    }
    
    private func setupMap() {
        kmController = KMController(viewContainer: kmContainer)
        kmController?.delegate = self
        kmController?.prepareEngine()
    }
    
    func bind() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                navigationController?.popViewController(animated: false)
            }).disposed(by: disposeBag)
    }
    
    func addViews() {
        MOALogger.logd()
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapViewInfo = MapviewInfo(viewName: "mapview", defaultPosition: defaultPosition, defaultLevel: 17)
        kmController?.addView(mapViewInfo)
    }
    
    func authenticationSucceeded() {
        MOALogger.logd()
        kmAuth = true
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        MOALogger.loge(desc)
        kmAuth = false
        
        // TODO 지도 로딩 몇번 실패 시 지도 안보여주기
    }
}

