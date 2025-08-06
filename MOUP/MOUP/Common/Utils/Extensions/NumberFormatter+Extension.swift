//
//  NumberFormatter+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/24/25.
//

import Foundation

import Then

extension NumberFormatter {
    /// 쉼표를 포함한 숫자 포맷터 (ex: 2,000,000)
    static let decimalFormatter = NumberFormatter().then {
        $0.numberStyle = .decimal
        $0.groupingSeparator = ","       // 천 단위 쉼표
        $0.maximumFractionDigits = 0     // 소수점 제거
        $0.locale = Locale(identifier: "ko_KR")
    }

    /// 문자열을 "2,000,000원" 형식으로 반환
    static func formattedWon(from number: String) -> String {
        // 쉼표 제거하고 Int로 변환
        guard let intVal = Int(number.replacingOccurrences(of: ",", with: "")) else {
            return number
        }
        // 포맷 후 "원" 붙이기
        return "\(decimalFormatter.string(from: NSNumber(value: intVal)) ?? number)원"
    }
    
    static func formattedDecimal(from number: String) -> String {
        guard let intVal = Int(number) else { return number }
        return decimalFormatter.string(from: NSNumber(value: intVal)) ?? number
    }
}

