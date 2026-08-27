//
//  PaySection.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// "급여" 섹션 — 급여 유형·계산·형태·급여일 행 4개
struct PaySection: View {
    @Binding var form: WorkplaceForm
    let onPayTypeTap: () -> Void
    let onPayCalculationTap: () -> Void
    let onSalaryTap: () -> Void
    let onPayDayTap: () -> Void

    var body: some View {
        ContainerView(title: "급여", isRequired: true) {
            LabelChevronRowView(titleLabel: "급여 유형",
                                rightLabel: form.salaryType?.displayText ?? "선택",
                                action: onPayTypeTap)
            LabelChevronRowView(titleLabel: "급여 계산",
                                rightLabel: form.salaryCalculation?.displayStr ?? "선택",
                                action: onPayCalculationTap)
            LabelChevronRowView(titleLabel: "급여 형태",
                                rightLabel: form.formattedSalaryAmount,
                                action: onSalaryTap)
            LabelChevronRowView(titleLabel: "급여일",
                                rightLabel: form.formattedPayDay,
                                action: onPayDayTap)
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var form = WorkplaceForm()

        var body: some View {
            ScrollView {
                PaySection(form: $form,
                          onPayTypeTap: {},
                          onPayCalculationTap: {},
                          onSalaryTap: {},
                          onPayDayTap: {})
                    .padding(.top, 20)
            }
            .background(.primaryBackground)
        }
    }
    return Wrapper()
}
