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

final class GifticonRegisterViewModel: BaseViewModel {
    private let gifticonService: GifticonServiceProtocol
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func createGifticon(
        image: UIImage,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) {
        if let data = image.pngData() {
            gifticonService.fetchCreateGifticon(
                image: data,
                name: name,
                expireDate: expireDate,
                store: store,
                memo: memo
            ).subscribe(onNext: { [weak self] response in
                MOALogger.logd("\(response)")
            }).disposed(by: disposeBag)
        }
    }
}
