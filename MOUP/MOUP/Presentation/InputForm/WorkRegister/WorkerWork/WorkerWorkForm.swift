//
//  WorkerWorkForm.swift
//  MOUP
//
//  Created by 서동환 on 8/16/26.
//

import Foundation

/// `WorkerWorkFormView`의 폼 상태를 담는 값 타입 (사장님 전용)
///
/// 사장님은 본인 근무와 근무자 근무를 모두 등록할 수 있어서 `target`으로 갈린다.
/// 서버 API가 둘을 다르게 다루므로(본인은 루틴 지정 가능, 근무자는 복수 지정 가능) 폼 하나가 두 DTO를 만든다.
struct WorkerWorkForm: Equatable {

    /// 누구의 근무를 등록하는지
    enum Target: Hashable {
        /// 사장님 본인 근무
        case owner
        /// 근무자 근무
        case worker
    }

    var target: Target
    var selectedWorkplace: WorkplaceSummary?
    /// 근무자 근무일 때만 쓴다. 등록은 복수, 수정은 항상 한 명이다.
    var selectedWorkers: [WorkerSummary]
    var selectedDate: Date
    var selectedStartTime: Date
    var selectedEndTime: Date
    var selectedBreakTime: Int
    var repeatDays: [String]
    var repeatEndDate: Date?
    /// 본인 근무에만 지정할 수 있다. 근무자 근무 API에는 루틴 필드가 없다.
    var routines: [RoutineSummary]
    var memo: String

    // MARK: - Initializer

    /// 등록 모드: 기본값으로 초기화
    init(selectedDate: Date = Date()) {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()

        self.target = .owner
        self.selectedWorkplace = nil
        self.selectedWorkers = []
        self.selectedDate = selectedDate

        let endTime = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        self.selectedEndTime = endTime
        self.selectedStartTime = calendar.date(byAdding: .hour, value: -6, to: endTime) ?? endTime

        self.selectedBreakTime = 0
        self.repeatDays = []
        self.repeatEndDate = nil
        self.routines = []
        self.memo = ""
    }

    /// 수정 모드: 기존 엔티티로부터 초기화
    ///
    /// 사장님 본인 근무와 근무자 근무는 수정 API가 다르므로 `isMyWork`로 대상을 가른다.
    init(workData: WorkerWorkData) {
        self.target = workData.isMyWork ? .owner : .worker
        self.selectedWorkplace = workData.workplaceSummary
        self.selectedWorkers = [workData.workerSummary]
        self.selectedStartTime = workData.startTime
        self.selectedEndTime = workData.endTime ?? workData.startTime
        self.selectedBreakTime = workData.restTimeMinutes
        self.repeatDays = workData.repeatDays
        self.routines = workData.routineSummaryInfoList
        self.memo = workData.memo ?? ""

        if let dateString = workData.repeatEndDate,
           let endDate = DateFormatter.dataSourceDateFormatter.date(from: dateString) {
            self.repeatEndDate = endDate
        } else {
            self.repeatEndDate = nil
        }

        if let date = DateFormatter.dataSourceDateFormatter.date(from: workData.workDate) {
            self.selectedDate = date
        } else {
            self.selectedDate = Date()
        }
    }

    // MARK: - Computed Properties

    var formattedDate: String {
        DateFormatter.dataSourceDateFormatter.string(from: selectedDate)
    }

    var formattedStartTime: String {
        DateFormatter.startEndTimeDateFormatter.string(from: selectedStartTime)
    }

    var formattedEndTime: String {
        DateFormatter.startEndTimeDateFormatter.string(from: selectedEndTime)
    }

    var formattedBreakTime: String {
        selectedBreakTime == 0 ? "없음" : "\(selectedBreakTime)분"
    }

    /// 선택한 근무자 표시 텍스트
    var formattedWorkers: String {
        selectedWorkers.map { $0.nickname }.joined(separator: ", ")
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

    /// 필수 필드가 모두 채워졌는지 여부
    var isValid: Bool {
        guard selectedWorkplace != nil,
              startDateTime != endDateTime,
              RepeatDays.isEndDateValid(repeatEndDate, from: selectedDate) else { return false }
        return target == .owner || !selectedWorkers.isEmpty
    }
}

// MARK: - DTO 변환

extension WorkerWorkForm {

    /// `selectedDate`의 연·월·일과 `time`의 시·분을 합쳐 절대 시각을 만든다.
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
    private var repeatEndDateString: String? {
        guard hasRepeat, let repeatEndDate else { return nil }
        return DateFormatter.yyyyMMdd.string(from: repeatEndDate)
    }

    /// 반복 요일 목록. 반복 설정이 완전하지 않으면 빈 배열
    private var repeatDaysForRequest: [String] {
        hasRepeat ? repeatDays : []
    }

    /// 사장님 본인 근무 등록 요청 DTO
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

    /// 근무자 근무 등록 요청 DTO
    var workersCreateRequestDTO: WorkersWorkCreateRequestDTO {
        WorkersWorkCreateRequestDTO(
            workerIdList: selectedWorkers.map { $0.id },
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

    /// 사장님 본인 근무 수정 요청 DTO
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

    /// 근무자 근무 수정 요청 DTO
    var updateRequestDTO: WorkerWorkUpdateRequestDTO {
        WorkerWorkUpdateRequestDTO(
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
