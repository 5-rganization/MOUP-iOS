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
    ///   - `decimal`: 근무시간 `Double`
    ///   - `workHour`:  최대 소수점 첫 번째 자리까지 표시하는 근무 시간 `String`
    static func calculateWorkHour(startTime: String, endTime: String, restTime: Int) -> (decimal: Double, str: String)? {
        guard let startDate = workHourDateFormatter.date(from: startTime),
              let endDate = workHourDateFormatter.date(from: endTime) else { return nil }
        
        let subtractedEndDate = Calendar.current.date(byAdding: .minute, value: -restTime, to: endDate) ?? endDate
        
        let todayOverEnd = subtractedEndDate < startDate ? Calendar.current.date(byAdding: .day, value: 1, to: subtractedEndDate) ?? subtractedEndDate : subtractedEndDate
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: todayOverEnd)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        let decimal = Double(hours) + Double(minutes) / 60.0
        let workHour: String
        if minutes >= 6 {
            workHour = "\(String(format: "%.1f", decimal))"
        } else {
            workHour = "\(hours)"
        }
        
        return (decimal, workHour)
    }
}
