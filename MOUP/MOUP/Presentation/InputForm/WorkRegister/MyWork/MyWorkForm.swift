//
//  MyWorkForm.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import Foundation

/// `MyWorkFormView`의 폼 상태를 담는 값 타입
///
/// UI 입력 상태와 도메인 엔티티(`MyWorkData`) 간 변환을 캡슐화합니다.
/// View에서는 `@State private var form = MyWorkForm()`으로 선언하여 사용합니다.
///
/// **사용 예시**
/// ```swift
/// // 등록 모드
/// @State private var form = MyWorkForm()
///
/// // 편집 모드
/// @State private var form = MyWorkForm(from: existingMyWorkData)
/// ```
struct MyWorkForm {
    var selectedWorkplace: WorkplaceSummary?
    var selectedDate: Date
    var selectedStartTime: Date
    var selectedEndTime: Date
    var actualStartTime: Date?
    var actualEndTime: Date?
    var selectedBreakTime: Int
    var repeatDays: [String]
    var repeatEndDate: Date?
    var routines: [RoutineSummary]
    var memo: String
    
    // MARK: - Initializer
    
    /// 등록 모드: 기본값으로 초기화
    init(
        selectedDate: Date = Date(),
        selectedStartTime: Date? = nil,
        selectedEndTime: Date? = nil,
        selectedBreakTime: Int = 0
    ) {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        
        self.selectedDate = selectedDate
        
        if let startTime = selectedStartTime, let endTime = selectedEndTime {
            self.selectedStartTime = startTime
            self.selectedEndTime = endTime
        } else {
            let endTime = calendar.dateInterval(of: .hour, for: now)?.start ?? now
            self.selectedEndTime = endTime
            self.selectedStartTime = calendar.date(byAdding: .hour, value: -6, to: endTime) ?? endTime
        }
        
        self.actualStartTime = nil
        self.actualEndTime = nil
        self.selectedBreakTime = selectedBreakTime
        self.repeatDays = []
        self.repeatEndDate = nil
        self.routines = []
        self.memo = ""
    }
    
    /// 편집 모드: 기존 엔티티로부터 초기화
    init(workData: MyWorkData) {
        self.selectedWorkplace = workData.workplaceSummary
        self.selectedStartTime = workData.startTime
        self.selectedEndTime = workData.endTime ?? workData.startTime
        self.actualStartTime = workData.actualStartTime
        self.actualEndTime = workData.actualEndTime
        self.selectedBreakTime = workData.restTimeMinutes
        self.repeatDays = workData.repeatDays
        self.routines = workData.routineSummaryList
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
    
    /// 반복 여부
    var hasRepeat: Bool {
        !repeatDays.isEmpty && repeatEndDate != nil
    }
    
    /// 반복 요일 표시 텍스트 (예: "월 / 수 / 금")
    var formattedRepeatDays: String {
        guard hasRepeat else { return "없음" }
        
        let dayMap: [String: String] = [
            "MONDAY": "월", "TUESDAY": "화", "WEDNESDAY": "수",
            "THURSDAY": "목", "FRIDAY": "금", "SATURDAY": "토", "SUNDAY": "일"
        ]
        let order = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
        
        return repeatDays
            .sorted { (order.firstIndex(of: $0) ?? 0) < (order.firstIndex(of: $1) ?? 0) }
            .compactMap { dayMap[$0] }
            .joined(separator: " / ")
    }
    
    var formattedRoutineCount: String {
        routines.count == 0 ? "" : "+ \(routines.count)"
    }
    
    /// 필수 필드가 모두 채워졌는지 여부
    var isValid: Bool {
        selectedWorkplace != nil && startDateTime != endDateTime
    }
}

// MARK: - DTO 변환

extension MyWorkForm {

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
    private var repeatEndDateString: String? {
        guard hasRepeat, let repeatEndDate else { return nil }
        return DateFormatter.dataSourceDateFormatter.string(from: repeatEndDate)
    }

    /// 반복 요일 목록. 반복 설정이 완전하지 않으면 빈 배열
    ///
    /// `repeatEndDateString`과 짝을 맞춰 요일만 선택하고 종료일을 비운 상태가 전송되지 않도록 한다.
    private var repeatDaysForRequest: [String] {
        hasRepeat ? repeatDays : []
    }

    /// 근무 등록 요청 DTO
    var createRequestDTO: MyWorkCreateRequestDTO {
        MyWorkCreateRequestDTO(
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

    /// 근무 수정 요청 DTO
    var updateRequestDTO: MyWorkUpdateRequestDTO {
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
