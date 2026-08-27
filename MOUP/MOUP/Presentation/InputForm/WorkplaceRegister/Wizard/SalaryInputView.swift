//
//  SalaryInputView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 시급/고정급 금액 입력 위저드
///
/// 네비바 타이틀·안내 문구는 `salaryCalculation`에 따라 "시급"/"고정급"으로 갈린다.
/// 기존 UIKit(`InputSalaryTypeView`)은 이 분기 API(`updateTitle`/`updatePlaceholder`)를 만들어 두고
/// 호출하지 않아 항상 "시급"으로 표시되는 오류가 있었다 — 여기서 분기를 붙여 완성한다.
struct SalaryInputView: View {
    @Binding var salaryAmount: Int
    let salaryCalculation: SalaryCalculation?
    @Environment(\.dismiss) private var dismiss

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var localAmount: Int

    init(salaryAmount: Binding<Int>, salaryCalculation: SalaryCalculation?) {
        self._salaryAmount = salaryAmount
        self.salaryCalculation = salaryCalculation
        self._localAmount = State(initialValue: salaryAmount.wrappedValue)
    }

    private var navTitle: String {
        salaryCalculation == .fixed ? "고정급" : "시급"
    }

    private var guideText: String {
        salaryCalculation == .fixed ? "고정급을 입력해주세요." : "시급을 입력해주세요."
    }

    private var placeholderText: String {
        salaryCalculation == .fixed ? "\(MinimumWage.monthly)원" : "\(MinimumWage.hourly)원"
    }

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: navTitle, onBackTap: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(guideText)
                        .font(.headBold(18))
                        .foregroundStyle(.gray900)

                    WizardTextFieldView(
                        placeholder: placeholderText,
                        text: Binding<String>(
                            get: { localAmount == 0 ? "" : NumberFormatter.formattedDecimal(from: String(localAmount)) },
                            set: { localAmount = Int($0.filter { $0.isNumber }) ?? 0 }
                        ),
                        keyboardType: .numberPad,
                        regexStr: "^[0-9,]*$"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
            }

            BaseButtonSU(title: "완료") {
                salaryAmount = localAmount
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .disabled(localAmount == 0)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(.primaryBackground)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var amount = 0

        var body: some View {
            NavigationStack {
                SalaryInputView(salaryAmount: $amount, salaryCalculation: .fixed)
            }
        }
    }
    return Wrapper()
}
