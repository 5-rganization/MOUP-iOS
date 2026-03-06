//
//  PickerRow.swift
//  MOUP
//
//  Created by 신영 on 3/5/26.
//

import SwiftUI

struct PickerRow: View {
    let title: String
    let buttonTitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text(title)
                    .font(.bodyMedium(16))
                    .foregroundStyle(.gray900)
                Spacer()
                Text(buttonTitle)
                    .font(.bodyMedium(16))
                    .foregroundStyle(.gray700)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.primary100)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
