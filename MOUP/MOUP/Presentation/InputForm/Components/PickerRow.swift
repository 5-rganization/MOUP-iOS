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
        // 히트 영역을 이 뷰의 프레임에 묶는다. 없으면 컨테이너 테두리 바깥 여백을 눌러도
        // 이 행이 눌린다 — 프레임 밖 10pt 남짓까지 반응하는 것을 실측했다(원인은 미확인).
        // label 안쪽에도 contentShape가 있지만 그것만으로는 막히지 않는다.
        .contentShape(Rectangle())
    }
}
