//
//  DateFormatter+Extension.swift
//  MOUP
//
//  Created by 서동환 on 6/18/25.
//

import Foundation

import Then

extension DateFormatter {
    /// Presentation 계층에서 연/월 형식을 만들기 위한 `DateFormatter`
    /// - `dateFormat`: `"yyyy. MM"`
    /// - `locale`: `"ko_KR"`
    /// - `timeZone`: `"Asia/Seoul"`
    static let presentaionYearMonthDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy. MM"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// Data 계층에서 연/월 형식을 만들기 위한 `DateFormatter`
    /// - `dateFormat`: `"yyyy-MM"`
    /// - `locale`: `"ko_KR"`
    /// - `timeZone`: `"Asia/Seoul"`
    static let dataYearMonthDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM"
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
    
    /// 근무 시간 표시용 `DateFormatter`
    /// - `dateFormat`: `"HH:mm"`
    /// - `locale`: `"ko_KR"`
    /// - `timeZone`: `"Asia/Seoul"`
    static let startEndTimeDateFormatter = DateFormatter().then {
        $0.dateFormat = "HH:mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
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
    ///
    /// 다른 포매터와 같은 시간대를 써야 한다. 파싱은 `dataSourceDateFormatter`(Asia/Seoul)로 하고
    /// 포맷만 기기 시간대로 하면, 해외 시간대에서 날짜가 하루씩 어긋난다.
    static let yyyyMMdd = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    /// Date -> "MM / dd / E"
    static let displayDate = DateFormatter().then {
        $0.dateFormat = "MM / dd / E"
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    static let displayTime = DateFormatter().then {
        $0.dateFormat = "HH : mm"
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
}
