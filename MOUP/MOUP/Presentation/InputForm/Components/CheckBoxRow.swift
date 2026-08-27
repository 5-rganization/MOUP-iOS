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
        // 히트 영역을 이 뷰의 프레임에 묶는다. 없으면 컨테이너 테두리 바깥 여백을 눌러도
        // 이 행이 눌린다 — 프레임 밖 10pt 남짓까지 반응하는 것을 실측했다(원인은 미확인).
        // label 안쪽에도 contentShape가 있지만 그것만으로는 막히지 않는다.
        .contentShape(Rectangle())
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
