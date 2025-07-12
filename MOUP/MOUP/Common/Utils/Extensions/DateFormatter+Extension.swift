//
//  DateFormatter+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

import Then

extension DateFormatter {
    /// `CalendarHeaderView`에서 `yearMonthLabel`의 연/월 형식을 만들기 위한 `DateFormatter`
    static let yearMonthDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy. MM"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// `CalendarView`에서 `dataSource` 관련 데이터의 연/월 형식을 만들기 위한 `DateFormatter`
    static let dataSourceDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
}
