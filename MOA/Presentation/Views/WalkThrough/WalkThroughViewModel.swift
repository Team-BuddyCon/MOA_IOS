//
//  WalkThroughViewModel.swift
//  MOA
//
//  Created by 오원석 on 5/11/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

public class WalkThroughViewModel: BaseViewModel, ViewModelType {
    struct Input {
        let changeWalkThroughPage: BehaviorRelay<Int>
        
    }
    
    struct Output {
        let updateWalkThrough: Driver<Int>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            updateWalkThrough: input.changeWalkThroughPage.asDriver()
        )
    }
}
