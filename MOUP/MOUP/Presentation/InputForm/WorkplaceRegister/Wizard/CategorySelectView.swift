//
//  CategorySelectView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import SwiftUI

/// 근무지 카테고리 선택 위저드
struct CategorySelectView: View {
    @Binding var category: WorkplaceCategory?
    @Environment(\.dismiss) private var dismiss

    /// 뒤로가기로 나가면 반영되지 않도록, 확정 전까지는 로컬에만 담는다.
    @State private var selected: WorkplaceCategory?

    init(category: Binding<WorkplaceCategory?>) {
        self._category = category
        self._selected = State(initialValue: category.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "카테고리", onBackTap: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("근무지 카테고리를 선택해주세요.")
                        .font(.headBold(18))
                        .foregroundStyle(.gray900)

                    ForEach(WorkplaceCategory.allCases, id: \.self) { item in
                        RadioButtonView(unselectedLeftImage: item.unselectedImage,
                                        selectedLeftImage: item.selectedImage,
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
                category = selected
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .disabled(selected == nil)
        }
        .toolbar(.hidden, for: .navigationBar)
        .swipeBackEnabled()
        .background(.primaryBackground)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var category: WorkplaceCategory?

        var body: some View {
            NavigationStack {
                CategorySelectView(category: $category)
            }
        }
    }
    return Wrapper()
}
