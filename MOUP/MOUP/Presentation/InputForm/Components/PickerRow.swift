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
        HStack(spacing: 0) {
            titleLabel
            Spacer()
            actionButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var titleLabel: some View {
        Text(title)
            .font(Font.bodyMedium(16))
            .foregroundColor(.gray900)
    }

    private var actionButton: some View {
        Button(action: onTap) {
            Text(buttonTitle)
                .font(Font.bodyMedium(16))
                .foregroundColor(.gray700)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.primary100)
                .cornerRadius(8)
        }
    }
}
