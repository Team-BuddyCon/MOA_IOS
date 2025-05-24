//
//  GifticonRegisterViewModel.swift
//  MOA
//
//  Created by 오원석 on 12/9/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class GifticonRegisterViewModel: BaseViewModel, ViewModelType {
    struct Input {
        let tapCancel: ControlEvent<Void>
        let tapImageZoomIn: ControlEvent<Void>
        let tapSave: ControlEvent<Void>
        let registerGifticon: PublishRelay<(UIImage, String, String, String, String?)>
    }
    
    struct Output {
        let showCancelAlert: Signal<Void>
        let showFullGifticonImage: Signal<Void>
        let isCheckRegister: Signal<Void>
        let loadingRegister: Signal<Void>
        let registerSuccess: Signal<String>
        let registerFail: Signal<Void>
    }

    private let gifticonService: GifticonServiceProtocol
    
    let loadingRegister = PublishRelay<Void>()
    let registerSuccess = PublishRelay<String>()
    let registerFail = PublishRelay<Void>()
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func transform(input: Input) -> Output {
        input.registerGifticon
            .flatMap { [unowned self] image, name, expireDate, gifticonStore, memo in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    loadingRegister.accept(())
                    return gifticonService.createGifticon(
                        data: data,
                        name: name,
                        expireDate: expireDate,
                        gifticonStore: gifticonStore,
                        memo: memo
                    ).map { gifticonId in
                        (gifticonId, expireDate, name)
                    }
                }
                return Observable.just(("","",""))
            }.subscribe(
                onNext: { [unowned self] gifticonId, expireDate, name in
                    if !gifticonId.isEmpty {
                        NotificationManager.shared.register(
                            expireDate,
                            name: name,
                            gifticonId: gifticonId
                        )
                        registerSuccess.accept(gifticonId)
                    } else {
                        registerFail.accept(())
                    }
                },
                onError: { [unowned self] _ in
                    registerFail.accept(())
                }
            ).disposed(by: disposeBag)
        
        return Output(
            showCancelAlert: input.tapCancel.asSignal(),
            showFullGifticonImage: input.tapImageZoomIn.asSignal(),
            isCheckRegister: input.tapSave.asSignal(),
            loadingRegister: loadingRegister.asSignal(),
            registerSuccess: registerSuccess.asSignal(),
            registerFail: registerFail.asSignal()
        )
    }
    
    func createGifticon(
        image: UIImage,
        name: String,
        expireDate: String,
        gifticonStore: String,
        memo: String?,
        onLoading: @escaping () -> Void,
        onSucess: @escaping (String) -> Void,
        onError: @escaping () -> Void
    ) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            onLoading()
            gifticonService.createGifticon(
                data: data,
                name: name,
                expireDate: expireDate,
                gifticonStore: gifticonStore,
                memo: memo
            ).subscribe(
                onNext: { gifticonId in
                    if !gifticonId.isEmpty {
                        NotificationManager.shared.register(
                            expireDate,
                            name: name,
                            gifticonId: gifticonId
                        )
                        onSucess(gifticonId)
                    }
                },
                onError: { error in
                    MOALogger.loge(error.localizedDescription)
                    onError()
                }
            ).disposed(by: disposeBag)
        }
    }
}
