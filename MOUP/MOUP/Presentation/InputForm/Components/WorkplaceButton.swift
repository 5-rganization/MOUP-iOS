//
//  WorkplaceButton.swift
//  MOUP
//
//  Created by 서동환 on 3/25/26.
//

import SwiftUI

struct WorkplaceButton: View {
    
    // MARK: - Properties

    /// 비활성화 상태에서는 필수 표시(`*`)와 꺾쇠를 숨긴다.
    @Environment(\.isEnabled) private var isEnabled

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
                    if isRequired, isEnabled {
                        Text(" *")
                            .foregroundColor(.accentColor)
                    }
                }
                .font(.headBold(18))
                .foregroundStyle(.gray900)
                
                Spacer()
                
                if isEnabled {
                    Image(.chevronRight)
                        .renderingMode(.template)
                        .foregroundStyle(.gray400)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(FormRowButtonStyle())
        // 히트 영역을 이 뷰의 프레임에 묶는다. 없으면 컨테이너 테두리 바깥 여백을 눌러도
        // 이 행이 눌린다 — 프레임 밖 10pt 남짓까지 반응하는 것을 실측했다(원인은 미확인).
        // label 안쪽에도 contentShape가 있지만 그것만으로는 막히지 않는다.
        .contentShape(Rectangle())
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
