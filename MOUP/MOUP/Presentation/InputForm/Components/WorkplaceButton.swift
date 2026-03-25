//
//  WorkplaceButton.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import SwiftUI

struct WorkplaceButton: View {
    
    // MARK: - Properties
    
    private let titleLabel: String
    private let isRequired: Bool
    private let action: () -> Void
    
    init(
        titleLabel: String,
        isRequired: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.titleLabel = titleLabel
        self.isRequired = isRequired
        self.action = action
    }
    
    // MARK: - Content
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 0) {
                    Text(titleLabel)
                    if isRequired {
                        Text(" *")
                            .foregroundColor(.accentColor)
                    }
                }
                .font(.headBold(18))
                .foregroundStyle(.gray900)
                
                Spacer()
                
                Image(.chevronRight)
                    .renderingMode(.template)
                    .foregroundStyle(.gray400)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .frame(height: 48)
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray400)
                .padding(.horizontal, 16)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        WorkplaceButton(titleLabel: "근무지 선택", isRequired: true)
        WorkplaceButton(titleLabel: "맥도날드", isRequired: false)
    }
}
