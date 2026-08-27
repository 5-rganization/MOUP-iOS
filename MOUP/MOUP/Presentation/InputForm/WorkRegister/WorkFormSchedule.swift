//
//  WorkFormSchedule.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import Foundation

/// 근무 폼이 공유하는 일정 필드와 그로부터 파생되는 표시·전송 값
///
/// `MyWorkForm`과 `WorkerWorkForm`이 같은 일정 필드를 갖고 같은 규칙으로 파생 값을 만든다.
/// 두 곳에 복제해 두면 야간 근무 처리나 날짜 포맷 규칙을 한쪽만 고치는 사고가 난다.
protocol WorkFormSchedule {
    var selectedDate: Date { get }
    var selectedStartTime: Date { get }
    var selectedEndTime: Date { get }
    var selectedBreakTime: Int { get }
    var repeatDays: [String] { get }
    var repeatEndDate: Date? { get }
    var routines: [RoutineSummary] { get }
    var memo: String { get }
}

// MARK: - 표시용 파생 값

extension WorkFormSchedule {

    var formattedStartTime: String {
        DateFormatter.startEndTimeDateFormatter.string(from: selectedStartTime)
    }

    var formattedEndTime: String {
        DateFormatter.startEndTimeDateFormatter.string(from: selectedEndTime)
    }

    var formattedBreakTime: String {
        selectedBreakTime == 0 ? "없음" : "\(selectedBreakTime)분"
    }

    /// 반복 여부
    var hasRepeat: Bool {
        !repeatDays.isEmpty && repeatEndDate != nil
    }

    /// 반복 요일 표시 텍스트
    var formattedRepeatDays: String {
        hasRepeat ? RepeatDays.formatted(repeatDays) : "없음"
    }

    var formattedRoutineCount: String {
        routines.isEmpty ? "" : "+ \(routines.count)"
    }
}

// MARK: - 시각 계산

extension WorkFormSchedule {

    /// `selectedDate`의 연·월·일과 `time`의 시·분을 합쳐 절대 시각을 만든다.
    ///
    /// 날짜와 시각을 별도 필드로 관리하기 때문에, 서버로 보낼 때는 하나로 합쳐야 한다.
    private func combined(_ time: Date) -> Date {
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComp = calendar.dateComponents([.hour, .minute], from: time)
        comp.hour = timeComp.hour
        comp.minute = timeComp.minute
        comp.second = 0
        return calendar.date(from: comp) ?? selectedDate
    }

    /// 출근 시각 (근무 날짜 기준)
    var startDateTime: Date {
        combined(selectedStartTime)
    }

    /// 퇴근 시각 (근무 날짜 기준)
    ///
    /// 퇴근이 출근보다 이르면 야간 근무로 보고 익일로 넘긴다. (예: 22:00 ~ 06:00)
    var endDateTime: Date {
        let end = combined(selectedEndTime)
        guard end <= startDateTime else { return end }
        return Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
    }

    /// 반복 종료일 문자열. 반복 설정이 완전하지 않으면 `nil`
    ///
    /// 서버는 `yyyy-MM-dd` 포맷을 요구한다. 표시용인 `dataSourceDateFormatter`(`yyyy.MM.dd`)를 쓰면 422가 반환된다.
    var repeatEndDateString: String? {
        guard hasRepeat, let repeatEndDate else { return nil }
        return DateFormatter.yyyyMMdd.string(from: repeatEndDate)
    }

    /// 반복 요일 목록. 반복 설정이 완전하지 않으면 빈 배열
    ///
    /// `repeatEndDateString`과 짝을 맞춰 요일만 선택하고 종료일을 비운 상태가 전송되지 않도록 한다.
    var repeatDaysForRequest: [String] {
        hasRepeat ? repeatDays : []
    }
}

// MARK: - 본인 근무 DTO 변환

extension WorkFormSchedule {

    /// 본인 근무 등록 요청 DTO
    var myCreateRequestDTO: MyWorkCreateRequestDTO {
        MyWorkCreateRequestDTO(
            routineIdList: routines.map { $0.routineId },
            startTime: startDateTime,
            // 서버가 nil을 "변경 없음"으로 보는지 "삭제"로 보는지 확인되지 않아, 기존 동작대로 항상 nil을 보낸다.
            actualStartTime: nil,
            endTime: endDateTime,
            actualEndTime: nil,
            restTimeMinutes: selectedBreakTime,
            memo: memo.isEmpty ? nil : memo,
            repeatDays: repeatDaysForRequest,
            repeatEndDate: repeatEndDateString
        )
    }

    /// 본인 근무 수정 요청 DTO
    ///
    /// 근무자 근무 수정 DTO와 달리 루틴을 포함한다. 본인 근무를 근무자 근무 DTO로 보내면 루틴이 지워진다.
    var myUpdateRequestDTO: MyWorkUpdateRequestDTO {
        MyWorkUpdateRequestDTO(
            routineIdList: routines.map { $0.routineId },
            startTime: startDateTime,
            actualStartTime: nil,
            endTime: endDateTime,
            actualEndTime: nil,
            restTimeMinutes: selectedBreakTime,
            memo: memo.isEmpty ? nil : memo,
            repeatDays: repeatDaysForRequest,
            repeatEndDate: repeatEndDateString
        )
    }
}
