//
//  CalendarEvent.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

/// 캘린더 근무 Entity
/// - `eventId`: 근무 ID `Int`
/// - `workplaceId`: 근무지/매장 ID `Int`
/// - `workplaceName`: 근무자/매장 이름 `String`
///   - 예시: "세븐일레븐 동탄제일점"
/// - `workerId`: 근무자 ID `Int`
/// - `workerName`: 근무자 이름 `String`
///   - 예시: "김알바"
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
/// - `colorLabel`: 라벨 색상 `String`
///   - 예시: "빨간색"
struct CalendarEvent {
    let eventId: Int
    let workplaceId: Int
    let workplaceName: String
    let workerId: Int
    let workerName: String
    let workDate: String
    let startTime: String
    let endTime: String
    let restTime: Int
    let memo: String
    let dailyIncome: Int
    let colorLabel: String
}
