//
//  LabelChevronRowView.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

/// (색상)-라벨-Chevron-(라벨) Row
struct LabelChevronRowView: View {
    
    // MARK: - Properties
    private let color: UIColor?
    private let frontLabel: String
    private let rearLabel: String?
    private let onTapAction: () -> Void
    
    // MARK: - Initializer
    init(
        color: UIColor? = nil,
        frontLabel: String,
        rearLabel: String? = nil,
        onTapAction: @escaping () -> Void = {}
    ) {
        self.color = color
        self.frontLabel = frontLabel
        self.rearLabel = rearLabel
        self.onTapAction = onTapAction
    }
    
    // MARK: - Content
    var body: some View {
        Button(action: onTapAction) {
            HStack(spacing: 12) {
                if let color {
                    Circle()
                        .fill(Color(uiColor: color))
                        .frame(width: 12, height: 12)
                }
                Text(frontLabel)
                    .font(.bodyMedium(16))
                
                Spacer()
                
                if let rearLabel {
                    Text(rearLabel)
                        .font(.fieldsRegular(16))
                }
                Image(.chevronRight)
            }
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .frame(height: 48)
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    LabelChevronRowView(color: .labelRed,
                        frontLabel: "루틴 추가",
                        rearLabel: "+ 1")
}
