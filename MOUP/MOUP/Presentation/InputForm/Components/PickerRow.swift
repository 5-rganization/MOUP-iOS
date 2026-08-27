//
//  PickerRow.swift
//  MOUP
//
//  Created by 신영 on 3/5/26.
//

import SwiftUI

struct PickerRow: View {
    
    // MARK: - Properties
    
    @Environment(\.isEnabled) private var isEnabled
    
    let title: String
    let buttonTitle: String
    let onTap: () -> Void

    // MARK: - Content
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text(title)
                    .font(.bodyMedium(16))
                    .foregroundStyle(.gray900)
                Spacer()
                if isEnabled {
                    // 활성화 상태: 캡슐 + 라벨
                    Text(buttonTitle)
                        .font(.bodyMedium(16))
                        .foregroundStyle(.gray700)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.primary100)
                        .cornerRadius(8)
                } else {
                    // 비활성화 상태: 라벨만 표시
                    Text(buttonTitle)
                        .font(.bodyMedium(16))
                        .foregroundStyle(.gray900)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(FormRowButtonStyle())
    }
}
