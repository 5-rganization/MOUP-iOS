//
//  MyWorkForm.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import Foundation

/// `MyWorkRegisterView`의 폼 상태를 담는 값 타입
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
    var selectedBreakTime: Int
    var repeatDays: [String]
    var repeatEndDate: Date?
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
        
        self.selectedBreakTime = selectedBreakTime
        self.repeatDays = []
        self.repeatEndDate = nil
        self.memo = ""
    }
    
    /// 편집 모드: 기존 엔티티로부터 초기화
    init(from data: MyWorkData) {
        self.selectedWorkplace = data.workplaceSummary
        self.selectedStartTime = data.startTime
        self.selectedEndTime = data.endTime ?? data.startTime
        self.selectedBreakTime = data.restTimeMinutes
        self.repeatDays = data.repeatDays
        self.memo = data.memo ?? ""
        
        if let dateString = data.repeatEndDate,
           let endDate = DateFormatter.dataSourceDateFormatter.date(from: dateString) {
            self.repeatEndDate = endDate
        } else {
            self.repeatEndDate = nil
        }
        
        if let date = DateFormatter.dataSourceDateFormatter.date(from: data.workDate) {
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
    
    /// 필수 필드가 모두 채워졌는지 여부
    var isValid: Bool {
        selectedWorkplace != nil
    }
}
