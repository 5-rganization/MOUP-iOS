//
//  Date+Extension.swift
//  MOUP
//
//  Created by 서동환 on 11/5/25.
//

import Foundation

extension Date {
    /// 날짜가 속한 월의 1일을 반환합니다. (시간은 00:00:00)
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        guard let startOfMonth = Calendar.current.date(from: components) else {
            assertionFailure("해당 Date의 구성 요소로부터 날짜를 생성할 수 없습니다.")
            return self
        }
        return startOfMonth
    }
    
    /// 날짜의 일을 반환합니다. (시간은 00:00:00)
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
}
