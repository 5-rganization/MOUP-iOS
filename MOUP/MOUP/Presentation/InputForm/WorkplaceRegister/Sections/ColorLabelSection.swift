//
//  ColorLabelSection.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// "라벨" 섹션 — 라벨 색상 행 하나
struct ColorLabelSection: View {
    @Binding var form: WorkplaceForm
    let onTap: () -> Void

    var body: some View {
        ContainerView(title: "라벨") {
            LabelChevronRowView(leftColor: form.labelColor.labelColor,
                                titleLabel: form.labelColor.displayStr,
                                action: onTap)
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var form = WorkplaceForm()

        var body: some View {
            ScrollView {
                ColorLabelSection(form: $form, onTap: {})
                    .padding(.top, 20)
            }
            .background(.primaryBackground)
        }
    }
    return Wrapper()
}
