//
//  DateFormatter+Extension.swift
//  MOUP
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

import Then

extension DateFormatter {
    /// `CalendarHeaderView`에서 `yearMonthLabel`의 연/월 형식을 만들기 위한 `DateFormatter`
    /// - `dateFormat`: `"yyyy. MM"`
    /// - `locale`: `"ko_KR"`
    /// - `timeZone`: `"Asia/Seoul"`
    static let yearMonthDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy. MM"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// `JTACMonthView`의 `dataSource` 관련 데이터의 연/월 형식을 만들기 위한 `DateFormatter`
    /// - `dateFormat`: `"yyyy.MM.dd"`
    /// - `locale`: `"ko_KR"`
    /// - `timeZone`: `"Asia/Seoul"
    static let dataSourceDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// 근무 시간 계산용 `DateFormatter`
    /// - `dateFormat`: `"HH:mm"`
    /// - `locale`: `"ko_KR"`
    /// - `timeZone`: `"Asia/Seoul"`
    static let workHourDateFormatter = DateFormatter().then {
        $0.dateFormat = "HH:mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// 근무 시간 계산 메서드
    /// - Parameters:
    ///   - startTime: 출근 시간
    ///   - endTime: 퇴근 시간
    ///   - restTime: 휴게 시간
    /// - Returns:
    ///   - `hoursInt`: 총 근무 시간 중 시간 `Int`
    ///   - `minutesInt`:  총 근무 시간 중 분 `Int`
    ///   - `str`:  최대 소수점 첫 번째 자리까지 표시하는 총 근무 시간 `String`
    ///   - `decimalForCalc`: 휴게 시간을 제외한 총 근무 시간(급여 계산용) `Double`
    ///   - 반환값 예시: `Optional(hoursInt: 1, minutesInt: 20, str: "1.3", decimalForCalc: 1.0833333333333333)`
    ///     - 입력값이 `startTime`: `"09:00"`, `endTime`: `"10:20"`, `restTime`: `15`인 경우의 반환값임
    static func calculateWorkHour(startTime: String, endTime: String, restTime: Int) -> (hoursInt: Int, minutesInt: Int, str: String, decimalForCalc: Double)? {
        guard let startDate = workHourDateFormatter.date(from: startTime),
              let endDate = workHourDateFormatter.date(from: endTime) else {
            assertionFailure("workHourDateFormatter로 변환 실패 - Argument가 올바르지 않습니다.")
            return nil
        }
        
        let calculatedDate: Date
        if endDate < startDate {
            calculatedDate = Calendar.current.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        } else {
            calculatedDate = endDate
        }
        
        let calculatedComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: calculatedDate)
        let calculatedHours = calculatedComponents.hour ?? 0
        let calculatedMinutes = calculatedComponents.minute ?? 0
        
        let workHourDecimal = Double(calculatedHours) + Double(calculatedMinutes) / 60.0
        let workHourStr: String
        if calculatedMinutes >= 6 {
            workHourStr = "\(String(format: "%.1f", workHourDecimal))"
        } else {
            workHourStr = "\(calculatedHours)"
        }
        
        let restTimeSubtractedEndDate = Calendar.current.date(byAdding: .minute, value: -restTime, to: calculatedDate) ?? calculatedDate
        let restTimeSubtractedComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: restTimeSubtractedEndDate)
        let restTimeSubtractedHours = restTimeSubtractedComponents.hour ?? 0
        let restTimeSubtractedMinutes = restTimeSubtractedComponents.minute ?? 0
        
        let workHourDecimalForCalc = Double(restTimeSubtractedHours) + Double(restTimeSubtractedMinutes) / 60.0
        
        return (calculatedHours, calculatedMinutes, workHourStr, workHourDecimalForCalc)
    }
    
    /// 한국어 12시간제 시:분 포매터 (예: "오전 9:30")
    static let ko12hTimeFormatter = DateFormatter().then {
        $0.dateFormat = "a h:mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// ISO8601 ("2025-10-11T08:30:00Z") -> Date
    static let iso8601Full = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(abbreviation: "UTC")
    }
    
    /// yyyy-MM-dd -> Date
    static let yyyyMMdd = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    /// Date -> "M/d E"
    static let displayDate = DateFormatter().then {
        $0.dateFormat = "M/d E"
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    static let displayTime = DateFormatter().then {
        $0.dateFormat = "HH : mm"
        $0.locale = Locale(identifier: "ko_KR")
    }
    
}
