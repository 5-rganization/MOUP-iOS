//
//  DatePickerModal.swift
//  MOUP
//
//  Created by 서동환 on 3/17/26.
//

import SwiftUI

struct DatePickerModal: View {
    
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var selectedDay: Int
    
    private let calendar = Calendar(identifier: .gregorian)
    
    // MARK: - Initializer
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        
        let date = selectedDate.wrappedValue
        let calendar = Calendar.current
        
        self._selectedYear = State(initialValue: calendar.component(.year, from: date))
        self._selectedMonth = State(initialValue: calendar.component(.month, from: date))
        self._selectedDay = State(initialValue: calendar.component(.day, from: date))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ModalGrabberViewSU()
                .padding(.top, 8)
            
            DatePickerViewSU(
                selectedYear: $selectedYear,
                selectedMonth: $selectedMonth,
                selectedDay: $selectedDay
            )
            .frame(height: 210)
            .padding(.top, 12)
            
            Spacer()
            
            HStack(spacing: 12) {
                BaseButtonSU(title: "취소", isSecondary: true) {
                    isPresented = false
                }
                
                BaseButtonSU(title: "선택") {
                    if let date = calendar.date(from: DateComponents(
                        year: selectedYear, month: selectedMonth, day: selectedDay
                    )) {
                        selectedDate = date
                    }
                    isPresented = false
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.primaryBackground)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State var date = Date()
        @State var isPresented = true
        
        var body: some View {
            DatePickerModal(selectedDate: $date, isPresented: $isPresented)
        }
    }
    return Wrapper()
}
