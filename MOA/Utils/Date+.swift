//
//  Date+.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import Foundation

extension Date {
    
    var timeInMills: Int {
        Int(self.timeIntervalSince1970 * 1000.0)
    }
    
    func add(offset: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(offset * 60 * 60 * 24))
    }
}
