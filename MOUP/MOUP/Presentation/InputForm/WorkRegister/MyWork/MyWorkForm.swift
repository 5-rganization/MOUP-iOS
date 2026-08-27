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
struct MyWorkForm: Equatable, WorkFormSchedule {
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
    
    /// 필수 필드가 모두 채워졌는지 여부
    var isValid: Bool {
        selectedWorkplace != nil
            && startDateTime != endDateTime
            && RepeatDays.isEndDateValid(repeatEndDate, from: selectedDate)
    }
}
