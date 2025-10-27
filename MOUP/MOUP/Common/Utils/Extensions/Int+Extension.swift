//
//  Int+Extension.swift
//  MOUP
//
//  Created by 송규섭 on 10/27/25.
//

import Foundation

extension Int {
    /// Int 타입으로 내려오는 TimeInterval 값을 hh시간 mm분 형태로 변환합니다.
    var timeString: String {
        let hours = self / 60
        let minutes = self % 60
        return "\(hours)시간 \(minutes)분"
    }
}
