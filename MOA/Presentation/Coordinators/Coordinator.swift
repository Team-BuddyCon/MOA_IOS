//
//  Coordinator.swift
//  MOA
//
//  Created by 오원석 on 5/6/25.
//

import Foundation

protocol Coordinator {
    var childs: [Coordinator] { get }
    func start()
}
