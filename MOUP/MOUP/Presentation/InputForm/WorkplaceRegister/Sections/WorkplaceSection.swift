//
//  WorkplaceSection.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// "근무지" 섹션 — 이름·카테고리 행 2개
struct WorkplaceSection: View {
    @Binding var form: WorkplaceForm
    let onNameTap: () -> Void
    let onCategoryTap: () -> Void

    var body: some View {
        ContainerView(title: "근무지", isRequired: true) {
            LabelChevronRowView(titleLabel: "이름",
                                rightLabel: form.workplaceName.isEmpty ? "입력" : form.workplaceName,
                                action: onNameTap)
            LabelChevronRowView(titleLabel: "카테고리",
                                rightLabel: form.category?.displayStr ?? "선택",
                                action: onCategoryTap)
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var form = WorkplaceForm()

        var body: some View {
            ScrollView {
                WorkplaceSection(form: $form, onNameTap: {}, onCategoryTap: {})
                    .padding(.top, 20)
            }
            .background(.primaryBackground)
        }
    }
    return Wrapper()
}
