//
//  UnAvailableGifticonViewModel.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class UnAvailableGifticonViewModel: BaseViewModel {
    
    struct Input {
        let viewWillAppear: PublishRelay<Void>
        let tapUsedGifticon: PublishRelay<String>
    }
    
    struct Output {
        let showUsedGifticons: Driver<[GifticonModel]>
        let showGifticonDetail: Signal<String>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let gifticonService: GifticonServiceProtocol
    private let usedGifticons = BehaviorRelay<[GifticonModel]>(value: [])
    
    init(gifticonService: GifticonServiceProtocol) {
        self.gifticonService = gifticonService
    }
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .flatMap { [unowned self] in
                gifticonService.fetchUsedGifticons()
            }.subscribe(onNext: { [unowned self] gifticons in
                usedGifticons.accept(gifticons.map { $0.toModel() })
            }).disposed(by: disposeBag)
        
        return Output(
            showUsedGifticons: usedGifticons.asDriver(),
            showGifticonDetail: input.tapUsedGifticon.asSignal()
        )
    }
}
