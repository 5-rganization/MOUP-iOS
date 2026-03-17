//
//  CalendarRange.swift
//  MOUP
//
//  Created by 서동환 on 7/26/25.
//

import Foundation

/// `JTACMonthView`의 날짜 생성 범위 설정용
enum CalendarRange {
    /// 캘린더 생성 시작 연도
    static let startYear = 2001
    /// 캘린더 생성 끝 연도
    static let endYear = 2100
    
    /// 2001.01.01 기준 캘린더 생성 시작 연도까지의 시간(초)
    static var startReferDate: Date {
        guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(startYear).01.01") else {
            return Date(timeIntervalSinceReferenceDate: 0.0)
        }
        return date
    }
    /// 2001.01.01 기준 캘린더 생성 끝 연도까지의 시간(초)
    static var endReferDate: Date {
        guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(endYear).12.31") else {
            return Date(timeIntervalSinceReferenceDate: 3_155_587_200.0)
        }
        return date
    }
}
