//
//  FirebaseLogEvent.swift
//  MOA
//
//  Created by 오원석 on 2/3/25.
//

import Foundation

enum FirebaseLogEvent: String {
    case withDraw = "withdraw"
}

enum FirebaseLogParameter: String {
    case withDrawReason = "withdraw_reason"
}
