//
//  WorkRepeatSettingsView.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import SwiftUI

struct WorkRepeatSettingsView: View {
    
    // MARK: - Properties
    
    /// 근무 날짜. 반복 종료일이 이보다 이르면 안 되므로 함께 받는다.
    private let workDate: Date

    @Binding var repeatDays: [String]
    @Binding var repeatEndDate: Date?
    
    @State private var tempDays: [String]
    @State private var tempEndDate: Date?
    @State private var isDatePickerPresented = false
    
    @Environment(\.dismiss) private var dismiss
    
    private var hasSelection: Bool {
        !tempDays.isEmpty
    }
    
    /// 종료일이 근무 날짜보다 이른지 여부
    private var isEndDateTooEarly: Bool {
        !RepeatDays.isEndDateValid(tempEndDate, from: workDate)
    }

    private var formattedRepeatEndDate: String {
        if let date = tempEndDate {
            return DateFormatter.dataSourceDateFormatter.string(from: date)
        }
        return "선택"
    }
    
    // MARK: - Initializer
    
    init(workDate: Date, repeatDays: Binding<[String]>, repeatEndDate: Binding<Date?>) {
        self.workDate = workDate
        self._repeatDays = repeatDays
        self._repeatEndDate = repeatEndDate
        self._tempDays = State(initialValue: repeatDays.wrappedValue)
        self._tempEndDate = State(initialValue: repeatEndDate.wrappedValue)
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "반복", onBackTap: {
                dismiss()
            })
            
            VStack(spacing: 24) {
                ContainerView {
                    CheckBoxRow(title: "일요일마다", isChecked: dayBinding("SUNDAY"))
                    CheckBoxRow(title: "월요일마다", isChecked: dayBinding("MONDAY"))
                    CheckBoxRow(title: "화요일마다", isChecked: dayBinding("TUESDAY"))
                    CheckBoxRow(title: "수요일마다", isChecked: dayBinding("WEDNESDAY"))
                    CheckBoxRow(title: "목요일마다", isChecked: dayBinding("THURSDAY"))
                    CheckBoxRow(title: "금요일마다", isChecked: dayBinding("FRIDAY"))
                    CheckBoxRow(title: "토요일마다", isChecked: dayBinding("SATURDAY"))
                }
                
                if hasSelection {
                    VStack(alignment: .leading, spacing: 8) {
                        ContainerView(title: "반복 종료 날짜를 입력해주세요") {
                            PickerRow(title: "날짜", buttonTitle: formattedRepeatEndDate) {
                                isDatePickerPresented = true
                            }
                        }

                        if isEndDateTooEarly {
                            Text("종료 날짜는 근무 날짜(\(DateFormatter.dataSourceDateFormatter.string(from: workDate))) 이후여야 합니다.")
                                .font(.bodyMedium(12))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                
                Spacer()
                
                BaseButtonSU(title: "적용하기") {
                    if tempDays.isEmpty {
                        repeatDays = []
                        repeatEndDate = nil
                    } else {
                        repeatDays = tempDays
                        repeatEndDate = tempEndDate
                    }
                    dismiss()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .disabled(!tempDays.isEmpty && (tempEndDate == nil || isEndDateTooEarly))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .swipeBackEnabled()
        .sheet(isPresented: $isDatePickerPresented) {
            DatePickerModal(
                selectedDate: Binding(
                    get: { tempEndDate ?? workDate },
                    set: { tempEndDate = $0 }
                ),
                isPresented: $isDatePickerPresented
            )
        }
    }
}

// MARK: - Private Methods

private extension WorkRepeatSettingsView {
    func dayBinding(_ key: String) -> Binding<Bool> {
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
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State var days: [String] = ["MONDAY", "FRIDAY"]
        @State var endDate: Date? = nil
        
        var body: some View {
            NavigationStack {
                WorkRepeatSettingsView(workDate: Date(), repeatDays: $days, repeatEndDate: $endDate)
            }
        }
    }
    return Wrapper()
}
