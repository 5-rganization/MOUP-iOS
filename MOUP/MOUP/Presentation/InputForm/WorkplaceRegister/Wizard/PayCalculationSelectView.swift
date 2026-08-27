//
//  PayCalculationSelectView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 급여 계산방법(시급/고정급) 선택 위저드
struct PayCalculationSelectView: View {
    @Binding var salaryCalculation: SalaryCalculation?
    @Environment(\.dismiss) private var dismiss

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var selected: SalaryCalculation?

    init(salaryCalculation: Binding<SalaryCalculation?>) {
        self._salaryCalculation = salaryCalculation
        self._selected = State(initialValue: salaryCalculation.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "급여 계산", onBackTap: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("급여 계산방법을 선택해주세요.")
                        .font(.headBold(18))
                        .foregroundStyle(.gray900)

                    ForEach(SalaryCalculation.allCases, id: \.self) { item in
                        RadioButtonView(label: item.displayStr,
                                        isSelected: selected == item) {
                            selected = item
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }

            BaseButtonSU(title: "완료") {
                salaryCalculation = selected
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .disabled(selected == nil)
        }
        .toolbar(.hidden, for: .navigationBar)
        .swipeBackEnabled()
        .background(.primaryBackground)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var salaryCalculation: SalaryCalculation?

        var body: some View {
            NavigationStack {
                PayCalculationSelectView(salaryCalculation: $salaryCalculation)
            }
        }
    }
    return Wrapper()
}
