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
struct WorkerWorkForm: Equatable, WorkFormSchedule {

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

    /// 선택한 근무자 표시 텍스트
    var formattedWorkers: String {
        selectedWorkers.map { $0.nickname }.joined(separator: ", ")
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
