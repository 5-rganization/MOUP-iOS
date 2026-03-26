//
//  BreakTimePickerModal.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import SwiftUI

struct BreakTimePickerModal: View {
    
    // MARK: - Properties
    
    /// 5분 단위: 0, 5, 10, ... , 120
    private let minuteOptions: [Int] = stride(from: 0, through: 120, by: 5).map { $0 }
    
    @Binding var selectedMinutes: Int
    @Binding var isPresented: Bool
    
    @State private var tempMinutes: Int
    
    // MARK: - Initializer
    
    init(selectedMinutes: Binding<Int>, isPresented: Binding<Bool>) {
        self._selectedMinutes = selectedMinutes
        self._isPresented = isPresented
        self._tempMinutes = State(initialValue: selectedMinutes.wrappedValue)
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack(spacing: 0) {
            ModalGrabberViewSU()
                .padding(.top, 8)
            
            Picker("", selection: $tempMinutes) {
                Text("없음")
                    .font(.headBold(20))
                    .foregroundStyle(.gray900)
                    .tag(0)
                
                ForEach(minuteOptions.dropFirst(), id: \.self) { value in
                    Text("\(value)분")
                        .font(.headBold(20))
                        .foregroundStyle(.gray900)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 210)
            .padding(.top, 12)
            
            Spacer()
            
            HStack(spacing: 12) {
                BaseButtonSU(title: "취소", isSecondary: true) {
                    isPresented = false
                }
                
                BaseButtonSU(title: "선택") {
                    selectedMinutes = tempMinutes
                    isPresented = false
                }
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
        @State var minutes = 30
        @State var isPresented = true
        
        var body: some View {
            BreakTimePickerModal(selectedMinutes: $minutes, isPresented: $isPresented)
        }
    }
    return Wrapper()
}
