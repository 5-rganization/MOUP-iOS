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
    
    /// `Int`값(분)을 `"H시간 m분"` 형태로 변환합니다.
    /// - 0분일 경우 시간만 표시합니다.
    var timeStringWithHideableMiniutes: String {
        let hours = self / 60
        let minutes = self % 60
        if minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(hours)시간"
        }
    }
    
    /// `Int`값(분)을 시간으로 변환하며, 0.1시간(6분) 미만의 소수점은 버립니다.
    /// - 예: 605분 (10시간 5분) ➡️ `"10시간"`
    /// - 예: 606분 (10시간 6분) ➡️ `"10.1시간"`
    /// - 예: 642분 (10시간 42분) ➡️ `"10.7시간"`
    var decimalTimeString: String {
        let hours = self / 60
        let minutes = self % 60
        
        if (minutes < 6) {
            return "\(hours)시간"
        } else {
            let minutesDecimal = Double(minutes) / 60.0
            let totalHours = Double(hours) + minutesDecimal
            return String(format: "%.1f시간", totalHours)
        }
    }
    
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
