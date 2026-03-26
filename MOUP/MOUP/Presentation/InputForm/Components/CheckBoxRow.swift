//
//  CheckBoxRow.swift
//  MOUP
//
//  Created by 신영 on 3/5/26.
//

import SwiftUI

struct CheckBoxRow: View {
    let title: String
    @Binding var isChecked: Bool
    let showInfo: Bool
    let onInfoTap: (() -> Void)?

    init(
        title: String,
        isChecked: Binding<Bool>,
        showInfo: Bool = false,
        onInfoTap: (() -> Void)? = nil
    ) {
        self.title = title
        self._isChecked = isChecked
        self.showInfo = showInfo
        self.onInfoTap = onInfoTap
    }

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: 0) {
                titleArea
                Spacer()
                checkBoxImage
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var titleArea: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.bodyMedium(16))
                .foregroundColor(.gray900)
            if showInfo {
                Button {
                    onInfoTap?()
                } label: {
                    Image(.info)
                }
            }
        }
    }

    private var checkBoxImage: some View {
        Image(isChecked ? .checkboxSelected : .checkboxUnselected)
    }
}
