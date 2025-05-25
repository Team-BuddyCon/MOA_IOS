//
//  BaseViewModel.swift
//  MOA
//
//  Created by 오원석 on 8/14/24.
//

import Foundation
import RxSwift

public protocol BaseViewModel {
    var disposeBag: DisposeBag { get }
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
