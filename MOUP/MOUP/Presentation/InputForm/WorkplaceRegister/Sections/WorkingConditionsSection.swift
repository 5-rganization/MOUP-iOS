//
//  WorkingConditionsSection.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// "근무 조건" 섹션 — 4대 보험(마스터 + 하위 4개) · 소득세 · 주휴수당 · 야간수당
///
/// 기존 UIKit(`WorkingConditionsContainerView`)에 4대 보험 안내 모달이 없어 `onInfoTap`을 두지 않는다.
struct WorkingConditionsSection: View {
    @Binding var form: WorkplaceForm

    var body: some View {
        ContainerView(title: "근무 조건") {
            CheckBoxRow(
                title: "4대 보험",
                isChecked: Binding(
                    get: { form.hasAllMajorInsurances },
                    set: { form.setAllMajorInsurances($0) }
                )
            )
            CheckBoxRow(title: "국민연금", isChecked: $form.hasNationalPension)
            CheckBoxRow(title: "건강보험", isChecked: $form.hasHealthInsurance)
            CheckBoxRow(title: "고용보험", isChecked: $form.hasEmploymentInsurance)
            CheckBoxRow(title: "산재보험", isChecked: $form.hasIndustrialAccident)
            CheckBoxRow(title: "소득세", isChecked: $form.hasIncomeTax)
            CheckBoxRow(title: "주휴수당", isChecked: $form.hasHolidayAllowance)
            CheckBoxRow(title: "야간수당", isChecked: $form.hasNightAllowance)
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var form = WorkplaceForm()

        var body: some View {
            ScrollView {
                WorkingConditionsSection(form: $form)
                    .padding(.top, 20)
            }
            .background(.primaryBackground)
        }
    }
    return Wrapper()
}
