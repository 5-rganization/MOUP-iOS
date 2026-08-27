//
//  ColorLabelSelectView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 라벨 색상 선택 위저드
struct ColorLabelSelectView: View {
    @Binding var labelColor: LabelColor
    @Environment(\.dismiss) private var dismiss

    /// 기존 `SelectColorLabelView`의 노출 순서를 그대로 따른다. `_default`는 선택지에 없다.
    private let options: [LabelColor] = [.red, .orange, .yellow, .green, .blue, .purple, .indigo]

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var selected: LabelColor

    init(labelColor: Binding<LabelColor>) {
        self._labelColor = labelColor
        self._selected = State(initialValue: labelColor.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "라벨 색상", onBackTap: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("라벨 색상을 선택해주세요.")
                        .font(.headBold(18))
                        .foregroundStyle(.gray900)

                    ForEach(options, id: \.self) { item in
                        let dot = UIImage.circle(color: item.labelColor, diameter: 24)
                        RadioButtonView(unselectedLeftImage: dot,
                                        selectedLeftImage: dot,
                                        label: item.displayStr,
                                        isSelected: selected == item) {
                            selected = item
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }

            BaseButtonSU(title: "완료") {
                labelColor = selected
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(.primaryBackground)
    }
}

// MARK: - Private Helpers

private extension UIImage {
    /// 단색 원형 이미지. `RadioButtonView`의 좌측 아이콘 슬롯에 색상 마커를 넣기 위한 용도.
    static func circle(color: UIColor, diameter: CGFloat) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        return UIGraphicsImageRenderer(size: size).image { _ in
            color.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var labelColor: LabelColor = ._default

        var body: some View {
            NavigationStack {
                ColorLabelSelectView(labelColor: $labelColor)
            }
        }
    }
    return Wrapper()
}
