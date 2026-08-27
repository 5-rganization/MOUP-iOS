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
    /// 고정급일 때 "얼마 주기의 금액인지"를 문구에 반영하기 위해 받는다.
    let salaryType: SalaryType?
    @Environment(\.dismiss) private var dismiss

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var localAmount: Int

    init(salaryAmount: Binding<Int>, salaryCalculation: SalaryCalculation?, salaryType: SalaryType?) {
        self._salaryAmount = salaryAmount
        self.salaryCalculation = salaryCalculation
        self.salaryType = salaryType
        self._localAmount = State(initialValue: salaryAmount.wrappedValue)
    }

    private var isFixed: Bool { salaryCalculation == .fixed }

    /// 고정급 한 건이 덮는 기간. 서버가 `salaryType`에 따라 이 금액을 곱해 월 급여를 만든다.
    private var periodText: String {
        switch salaryType {
        case .weekly: return "한 주"
        case .daily: return "하루"
        default: return "한 달"
        }
    }

    private var navTitle: String {
        isFixed ? "고정급" : "시급"
    }

    /// 고정급은 지급 주기를 밝힌다. 서버는 매주면 그 달의 지급 횟수만큼, 매일이면 근무일 수만큼
    /// 이 금액을 곱하므로, "고정급"이라고만 하면 사용자가 월 총액을 넣어 급여가 몇 배로 부풀 수 있다.
    private var guideText: String {
        isFixed ? "\(periodText)에 받는 고정급을 입력해주세요." : "시급을 입력해주세요."
    }

    /// 최저임금은 시급과 월급 기준만 있다. 주급·일급 고정급에 월 최저임금을 힌트로 두면
    /// 그 자체가 잘못된 금액을 유도하므로, 그때는 예시 금액을 보여주지 않는다.
    private var placeholderText: String {
        guard isFixed else { return "\(MinimumWage.hourly)원" }
        return salaryType == .monthly ? "\(MinimumWage.monthly)원" : "금액 입력"
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
        .swipeBackEnabled()
        .background(.primaryBackground)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var amount = 0

        var body: some View {
            NavigationStack {
                SalaryInputView(salaryAmount: $amount, salaryCalculation: .fixed, salaryType: .weekly)
            }
        }
    }
    return Wrapper()
}
