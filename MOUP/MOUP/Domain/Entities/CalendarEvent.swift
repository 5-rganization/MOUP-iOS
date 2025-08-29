//
//  CalendarEvent.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

/// 캘린더 근무 Entity
/// - `id`: 근무 ID `Int64`
/// - `workplaceId`: 근무지/매장 ID `Int64`
/// - `workplaceName`: 근무자/매장 이름 `String`
///   - 예시: `"세븐일레븐 동탄제일점"`
/// - `workerId`: 근무자 ID `Int64`
/// - `workerName`: 근무자 이름 `String`
///   - 예시: `"김알바"`
/// - `workDate`: 근무 날짜 `String`
///   - 형식: `"yyyy.MM.dd"`
///   - 예시: `"2025.08.14"`
/// - `startTime`: 출근 시간 `String`
///   - 형식: `"hh:MM"`
///   - 예시: `"09:00"`
/// - `endTime`: 퇴근 시간 `String`
///   - 형식: `"hh:MM"`
///   - 예시: `"20:00"`
/// - `restTime`: 휴게 시간 `Int`
///   - 예시: `60`
/// - `memo`: 메모 `String`
///   - 예시: `"메모입니다."`
/// - `salaryCalculation`: 급여 계산 `SalaryCalculation`
///   - 예시: `.hourly`
/// - `dailyIncome`: 일급 `Int`
///   - 예시: `100300`
/// - `colorLabel`: 라벨 색상 `String`
///   - 예시: `"빨간색"`
/// - `isShared`: 공유 여부 `Bool`
struct CalendarEvent {
    let id: Int64
    let workplaceId: Int64
    let workplaceName: String
    let workerId: Int64
    let workerName: String
    let workDate: String
    let startTime: String
    let endTime: String
    let restTime: Int
    let memo: String
    let salaryCalculation: SalaryCalculation
    let dailyIncome: Int
    let labelColor: String
    let isShared: Bool
}
