//
//  Date+Extension.swift
//  MOUP
//
//  Created by 서동환 on 11/5/25.
//

import Foundation

extension Date {
    /// 현재 날짜가 속한 월의 1일을 반환합니다. (시간은 00:00:00)
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
}
