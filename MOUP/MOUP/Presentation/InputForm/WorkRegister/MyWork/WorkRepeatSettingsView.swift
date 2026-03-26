//
//  WorkRepeatSettingsView.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import SwiftUI

struct WorkRepeatSettingsView: View {
    
    // MARK: - Properties
    
    @Binding var repeatDays: [String]
    @Binding var repeatEndDate: Date?
    
    /// 임시 편집 상태
    @State private var tempDays: [String]
    @State private var tempEndDate: Date?
    @State private var isDatePickerPresented = false
    
    @Environment(\.dismiss) private var dismiss
    
    /// 요일 목록 (API 키 + 표시 텍스트)
    private let weekdays: [(key: String, label: String)] = [
        ("SUNDAY", "일요일마다"),
        ("MONDAY", "월요일마다"),
        ("TUESDAY", "화요일마다"),
        ("WEDNESDAY", "수요일마다"),
        ("THURSDAY", "목요일마다"),
        ("FRIDAY", "금요일마다"),
        ("SATURDAY", "토요일마다")
    ]
    
    private var hasSelection: Bool {
        !tempDays.isEmpty
    }
    
    private var formattedRepeatEndDate: String {
        if let date = tempEndDate {
            return DateFormatter.dataSourceDateFormatter.string(from: date)
        }
        return "선택"
    }
    
    // MARK: - Initializer
    
    init(repeatDays: Binding<[String]>, repeatEndDate: Binding<Date?>) {
        self._repeatDays = repeatDays
        self._repeatEndDate = repeatEndDate
        self._tempDays = State(initialValue: repeatDays.wrappedValue)
        self._tempEndDate = State(initialValue: repeatEndDate.wrappedValue)
    }
    
    // MARK: - Private Methods
    
    private func dayBinding(_ key: String) -> Binding<Bool> {
        Binding(
            get: { tempDays.contains(key) },
            set: { isOn in
                if isOn {
                    if !tempDays.contains(key) {
                        tempDays.append(key)
                    }
                } else {
                    tempDays.removeAll { $0 == key }
                    if tempDays.isEmpty {
                        tempEndDate = nil
                    }
                }
            }
        )
    }
    
    // MARK: - Content
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ContainerView(title: "반복 요일을 선택해주세요") {
                        CheckBoxRow(
                            title: "일요일마다",
                            isChecked: dayBinding("SUNDAY")
                        )
                        CheckBoxRow(
                            title: "월요일마다",
                            isChecked: dayBinding("MONDAY")
                        )
                        CheckBoxRow(
                            title: "화요일마다",
                            isChecked: dayBinding("TUESDAY")
                        )
                        CheckBoxRow(
                            title: "수요일마다",
                            isChecked: dayBinding("WEDNESDAY")
                        )
                        CheckBoxRow(
                            title: "목요일마다",
                            isChecked: dayBinding("THURSDAY")
                        )
                        CheckBoxRow(
                            title: "금요일마다",
                            isChecked: dayBinding("FRIDAY")
                        )
                        CheckBoxRow(
                            title: "토요일마다",
                            isChecked: dayBinding("SATURDAY")
                        )
                    }
                }
                
                if hasSelection {
                    ContainerView(title: "반복 종료 날짜를 입력해주세요") {
                        PickerRow(title: "날짜", buttonTitle: formattedRepeatEndDate) {
                            isDatePickerPresented = true
                        }
                    }
                }
                
                BaseButtonSU(title: "등록하기") {
                    if tempDays.isEmpty {
                        // 아무것도 선택 안 했으면 "없음" 처리
                        repeatDays = []
                        repeatEndDate = nil
                    } else {
                        repeatDays = tempDays
                        repeatEndDate = tempEndDate
                    }
                    dismiss()
                }
                .frame(height: 48)
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $isDatePickerPresented) {
            DatePickerModal(
                selectedDate: Binding(
                    get: { tempEndDate ?? Date() },
                    set: { tempEndDate = $0 }
                ),
                isPresented: $isDatePickerPresented
            )
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State var days: [String] = ["MONDAY", "FRIDAY"]
        @State var endDate: Date? = nil
        
        var body: some View {
            NavigationStack {
                WorkRepeatSettingsView(repeatDays: $days, repeatEndDate: $endDate)
            }
        }
    }
    return Wrapper()
}
