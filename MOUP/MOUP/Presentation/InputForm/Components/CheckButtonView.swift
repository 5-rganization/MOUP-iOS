//
//  CheckButtonView.swift
//  MOUP
//
//  Created by 서동환 on 3/26/26.
//

import SwiftUI

/// 체크 버튼 뷰
///
/// SwiftUI로 구현한 체크 버튼으로, 선택/비선택 상태에 따라
/// 테두리 색상·두께, 텍스트 색상·폰트, 좌측 아이콘, 우측 체크 이미지가 변경됩니다.
/// 옵션으로 좌측에 아이콘 이미지를 배치할 수 있으며, 선택/비선택 상태별로 다른 아이콘을 지정합니다.
///
/// **사용 예시:**
/// ```swift
/// struct ParentView: View {
///     @State private var first = false
///     @State private var second = false
///
///     var body: some View {
///         // 아이콘 없는 버전
///         CheckButtonView(title: "맥도날드", isSelected: $first)
///
///         // 아이콘 있는 버전
///         CheckButtonView(
///             selectedIcon: Image(.iconSelected),
///             unselectedIcon: Image(.iconUnselected),
///             title: "스타벅스",
///             isSelected: $second
///         )
///     }
/// }
/// ```
struct CheckButtonView: View {
    
    // MARK: - Properties
    
    private let selectedIcon: Image?
    private let unselectedIcon: Image?
    private let title: String
    @Binding private var isSelected: Bool
    
    // MARK: - Initializer
    
    /// 새로운 `CheckButtonView`를 생성합니다.
    ///
    /// - Parameters:
    ///   - selectedIcon: 선택 상태일 때 좌측에 표시될 아이콘 이미지입니다. `nil`일 경우 표시되지 않습니다. 기본값은 `nil`입니다.
    ///   - unselectedIcon: 비선택 상태일 때 좌측에 표시될 아이콘 이미지입니다. `nil`일 경우 표시되지 않습니다. 기본값은 `nil`입니다.
    ///   - title: 타이틀 텍스트입니다.
    ///   - isSelected: 선택 상태를 양방향으로 공유할 바인딩(`@Binding`)입니다.
    init(
        selectedIcon: Image? = nil,
        unselectedIcon: Image? = nil,
        title: String,
        isSelected: Binding<Bool>
    ) {
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon
        self.title = title
        self._isSelected = isSelected
    }
    
    // MARK: - Content
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: 8) {
                if let icon = isSelected ? selectedIcon : unselectedIcon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(title)
                    .font(isSelected ? .headBold(16) : .bodyMedium(16))
                    .foregroundStyle(isSelected ? .primary600 : .gray900)
                
                Spacer()
                
                if isSelected {
                    Image(.check)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.primary500 : Color.gray400,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var first = false
        @State private var second = true
        @State private var third = false
        
        var body: some View {
            VStack(spacing: 12) {
                CheckButtonView(title: "맥도날드", isSelected: $first)
                CheckButtonView(title: "스타벅스", isSelected: $second)
                CheckButtonView(
                    selectedIcon: Image(.cafeSelected),
                    unselectedIcon: Image(.cafeUnselected),
                    title: "아이콘 있는 버전",
                    isSelected: $third
                )
            }
            .padding(.horizontal, 16)
        }
    }
    return Wrapper()
}
