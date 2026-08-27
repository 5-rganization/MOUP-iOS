//
//  NameInputView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 근무지 이름 입력 위저드
struct NameInputView: View {
    @Binding var workplaceName: String
    @Environment(\.dismiss) private var dismiss

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var localName: String

    init(workplaceName: Binding<String>) {
        self._workplaceName = workplaceName
        self._localName = State(initialValue: workplaceName.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "근무지 입력", onBackTap: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("근무지 이름을 입력해주세요.")
                        .font(.headBold(18))
                        .foregroundStyle(.gray900)

                    WizardTextFieldView(placeholder: "근무지 명", text: $localName)
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
            }

            BaseButtonSU(title: "완료") {
                workplaceName = localName
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .disabled(localName.isEmpty)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(.primaryBackground)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var name = ""

        var body: some View {
            NavigationStack {
                NameInputView(workplaceName: $name)
            }
        }
    }
    return Wrapper()
}
