//
//  Date+.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import Foundation

let AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT = "yyyy-MM-dd"
let AVAILABLE_GIFTICON_UI_TIME_FORMAT = "yyyy.MM.dd"

extension Date {
    var timeInMills: Int {
        Int(self.timeIntervalSince1970 * 1000.0)
    }
    
    func add(offset: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(offset * 60 * 60 * 24))
    }
}

extension String {
    func transformTimeformat(
        origin: String,
        dest: String
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = origin
        
        let destFormatter = DateFormatter()
        destFormatter.dateFormat = dest
        
        if let date = formatter.date(from: self) {
            return destFormatter.string(from: date)
        }
        
        return ""
    }
}
