//
//  Date+.swift
//  MOA
//
//  Created by 오원석 on 10/1/24.
//

import Foundation

// 기프티콘 조회 API : yyyy.MM.dd 형태로 반환
// 상세 기프티콘 조회 API : yyyy-MM-dd 형태로 반환
let AVAILABLE_GIFTICON_RESPONSE_TIME_FORMAT = "yyyy-MM-dd"
let AVAILABLE_GIFTICON_TIME_FORMAT = "yyyy.MM.dd"
let AVAILABLE_GIFTICON_TIME_FORMAT2 = "yyyy년 MM월 dd일"

extension Date {
    var timeInMills: Int {
        Int(self.timeIntervalSince1970 * 1000.0)
    }
    
    func add(offset: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(offset * 60 * 60 * 24))
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String {
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    func toDday() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = AVAILABLE_GIFTICON_TIME_FORMAT
        let date = formatter.date(from: self) ?? Date()
        
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: Date())
        let toDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    }
    
    func toDTime() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = AVAILABLE_GIFTICON_TIME_FORMAT
        let date = formatter.date(from: self) ?? Date()
        let calendar = Calendar.current
        return calendar.dateComponents([.hour], from: Date(), to: date).hour ?? 0
    }
    
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
