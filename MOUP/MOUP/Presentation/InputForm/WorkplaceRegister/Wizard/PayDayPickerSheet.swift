//
//  PayDayPickerSheet.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 급여일(1~31일) 선택 시트
struct PayDayPickerSheet: View {
    private let dayRange = Array(1...31)

    @Binding var payDay: Int
    @Binding var isPresented: Bool

    @State private var tempDay: Int

    init(payDay: Binding<Int>, isPresented: Binding<Bool>) {
        self._payDay = payDay
        self._isPresented = isPresented
        self._tempDay = State(initialValue: payDay.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            ModalGrabberViewSU()
                .padding(.top, 8)

            Picker("", selection: $tempDay) {
                ForEach(dayRange, id: \.self) { day in
                    Text("\(day)일")
                        .font(.headBold(20))
                        .foregroundStyle(.gray900)
                        .tag(day)
                }
            }
            .pickerStyle(.wheel)
            .padding(.top, 12)
            .frame(height: 210)

            Spacer()

            HStack(spacing: 12) {
                BaseButtonSU(title: "취소", isSecondary: true) {
                    isPresented = false
                }

                BaseButtonSU(title: "선택") {
                    payDay = tempDay
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
        @State var day = 1
        @State var isPresented = true

        var body: some View {
            PayDayPickerSheet(payDay: $day, isPresented: $isPresented)
        }
    }
    return Wrapper()
}
