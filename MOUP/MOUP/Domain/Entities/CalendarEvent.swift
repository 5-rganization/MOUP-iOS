//
//  CalendarEvent.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

/// 캘린더 근무 Entity
/// - `workDate`: 근무 날짜 `String`
///   - 예시: "2025.08.14"
/// - `startTime`: 출근 시간 `String`
///   - 예시: "09:00"
/// - `endTime`: 퇴근 시간 `String`
///   - 예시: "20:00"
/// - `restTime`: 휴게 시간 `Int`
///   - 예시: 60
/// - `memo`: 메모 `String`
///   - 예시: "메모입니다."
/// - `dailyIncome`: 일급 `Int`
///   - 예시: 100300
struct CalendarEvent {
    let workDate: String
    let startTime: String
    let endTime: String
    let restTime: Int
    let memo: String
    let dailyIncome: Int
}
