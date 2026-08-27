//
//  PayTypeSelectView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 급여 유형(매월/매주/매일) 선택 위저드
struct PayTypeSelectView: View {
    @Binding var salaryType: SalaryType?
    @Environment(\.dismiss) private var dismiss

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var selected: SalaryType?

    init(salaryType: Binding<SalaryType?>) {
        self._salaryType = salaryType
        self._selected = State(initialValue: salaryType.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "급여 유형", onBackTap: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("급여 유형을 선택해주세요.")
                        .font(.headBold(18))
                        .foregroundStyle(.gray900)

                    ForEach(SalaryType.allCases, id: \.self) { item in
                        RadioButtonView(label: item.displayText,
                                        isSelected: selected == item) {
                            selected = item
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }

            BaseButtonSU(title: "완료") {
                salaryType = selected
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
        @State private var salaryType: SalaryType?

        var body: some View {
            NavigationStack {
                PayTypeSelectView(salaryType: $salaryType)
            }
        }
    }
    return Wrapper()
}
