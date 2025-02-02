//
//  WithDrawViewModel.swift
//  MOA
//
//  Created by 오원석 on 2/1/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class WithDrawViewModel: BaseViewModel {
    
    let phrase = BehaviorRelay(value: WithDrawPhrase.Reason)
    let reason = BehaviorRelay(value: WithDrawReason.NotUseApp)
}

