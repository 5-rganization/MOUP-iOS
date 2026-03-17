//
//  TimePickerModal.swift
//  MOUP
//
//  Created by 서동환 on 3/17/26.
//

import SwiftUI

struct TimePickerModal: View {
    
    // MARK: - Properties
    
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    
    @State private var tempHour24: Int
    @State private var tempMinute: Int
    
    private let calendar = Calendar(identifier: .gregorian)
    
    // MARK: - Initializer
    
    init(selectedTime: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedTime = selectedTime
        self._isPresented = isPresented
        
        let date = selectedTime.wrappedValue
        let calendar = Calendar(identifier: .gregorian)
        self._tempHour24 = State(initialValue: calendar.component(.hour, from: date))
        self._tempMinute = State(initialValue: calendar.component(.minute, from: date))
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack(spacing: 0) {
            ModalGrabberViewSU()
                .padding(.top, 8)
            
            TimePickerViewSU(
                hour24: $tempHour24,
                minute: $tempMinute
            )
            .frame(height: 210)
            .padding(.top, 12)
            
            Spacer()
            
            HStack(spacing: 12) {
                BaseButtonSU(title: "취소", isSecondary: true) {
                    isPresented = false
                }
                .frame(height: 48)
                
                BaseButtonSU(title: "선택") {
                    var components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
                    components.hour = tempHour24
                    components.minute = tempMinute
                    components.second = 0
                    if let newDate = calendar.date(from: components) {
                        selectedTime = newDate
                    }
                    isPresented = false
                }
                .frame(height: 48)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
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
        @State var time = Date()
        @State var isPresented = true
        
        var body: some View {
            TimePickerModal(selectedTime: $time, isPresented: $isPresented)
        }
    }
    return Wrapper()
}
