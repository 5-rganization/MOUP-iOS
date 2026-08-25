//
//  RepeatDays.swift
//  MOUP
//
//  Created by 서동환 on 8/16/26.
//

import Foundation

/// 반복 요일 코드(`"MONDAY"` 등)를 화면 표시용 문자열로 바꾼다.
///
/// 알바생 폼과 사장님 폼이 같은 규칙을 쓰므로 한곳에 둔다.
enum RepeatDays {

    private static let weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]
    private static let weekend = ["SATURDAY", "SUNDAY"]

    private static let dayNames: [String: String] = [
        "MONDAY": "월", "TUESDAY": "화", "WEDNESDAY": "수",
        "THURSDAY": "목", "FRIDAY": "금", "SATURDAY": "토", "SUNDAY": "일"
    ]

    /// 반복 종료일이 근무 날짜 이후인지 여부. 종료일이 없으면 판단할 것이 없으므로 `true`
    ///
    /// 서버도 막지만, 사용자가 이유를 알 수 있도록 고르는 화면에서 먼저 걸러낸다.
    static func isEndDateValid(_ endDate: Date?, from workDate: Date) -> Bool {
        guard let endDate else { return true }
        let calendar = Calendar.current
        return calendar.startOfDay(for: endDate) >= calendar.startOfDay(for: workDate)
    }

    /// 하루면 "목요일마다", 전부면 "매일", 월~금이면 "평일", 토·일이면 "주말", 그 외에는 "월, 수, 금"으로 표시한다.
    static func formatted(_ days: [String]) -> String {
        let selected = Set(days)

        if selected == Set(weekdays + weekend) { return "매일" }
        if selected == Set(weekdays) { return "평일" }
        if selected == Set(weekend) { return "주말" }

        let order = weekdays + weekend
        let names = days
            .sorted { (order.firstIndex(of: $0) ?? 0) < (order.firstIndex(of: $1) ?? 0) }
            .compactMap { dayNames[$0] }

        guard let onlyDay = names.first, names.count == 1 else {
            return names.joined(separator: ", ")
        }
        return "\(onlyDay)요일마다"
    }
}
