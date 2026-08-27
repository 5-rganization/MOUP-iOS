//
//  ContainerView.swift
//  MOUP
//
//  Created by 신영 on 3/5/26.
//

import SwiftUI

struct ContainerView: View {
    /// 비활성화 상태에서는 입력이 불가하므로 필수 표시(`*`)를 숨긴다.
    @Environment(\.isEnabled) private var isEnabled

    let title: String?
    let isRequired: Bool?
    let rows: [AnyView]

    init(
        title: String? = nil,
        isRequired: Bool? = nil,
        @SectionRowBuilder content: () -> [AnyView]
    ) {
        self.title = title
        self.isRequired = isRequired
        self.rows = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView
            containerBox
        }
        .padding(.horizontal, 16)
    }

    private var titleView: some View {
        HStack(spacing: 0) {
            if let title {
                Text(title)
                if let isRequired, isRequired == true, isEnabled {
                    Text(" *")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .font(.headBold(18))
        .foregroundColor(.gray900)
    }

    private var containerBox: some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { index in
                rows[index]
                if index < rows.count - 1 {
                    Divider()
                        .frame(height: 1)
                        .overlay(.gray400)
                }
            }
        }
        // 행이 눌림 배경 같은 자체 배경을 그리면 모서리를 넘어 각지게 삐져나온다.
        // 테두리보다 먼저 잘라내야 한다.
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray400, lineWidth: 1)
        )
    }
}

@resultBuilder
struct SectionRowBuilder {
    static func buildBlock(_ components: any View...) -> [AnyView] {
        components.map { AnyView($0) }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ContainerView(title: "4대 보험") {
                CheckBoxRow(title: "4대 보험", isChecked: .constant(true), showInfo: true)
                CheckBoxRow(title: "국민연금", isChecked: .constant(false), showInfo: true)
                CheckBoxRow(title: "건강보험", isChecked: .constant(true))
                CheckBoxRow(title: "고용보험", isChecked: .constant(false))
                CheckBoxRow(title: "산재보험", isChecked: .constant(false))
                CheckBoxRow(title: "소득세", isChecked: .constant(true))
            }

            ContainerView(title: "수당 옵션") {
                CheckBoxRow(title: "주휴수당", isChecked: .constant(false), showInfo: true)
                CheckBoxRow(title: "야간수당", isChecked: .constant(false))
            }

            ContainerView(title: "근무 시간", isRequired: true) {
                PickerRow(title: "출근", buttonTitle: "선택") {}
                PickerRow(title: "퇴근", buttonTitle: "선택") {}
                PickerRow(title: "휴게", buttonTitle: "없음") {}
            }

            ContainerView(title: "근무 날짜", isRequired: true) {
                PickerRow(title: "날짜", buttonTitle: "2026.03.05") {}
            }
        }
        .padding(.vertical, 32)
    }
    .background(.white)
}
