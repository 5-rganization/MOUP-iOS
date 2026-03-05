//
//  RadioButtonView.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

/// 라디오버튼 (라벨only, 이미지-라벨)
///
/// 이 뷰는 내부적으로 상태를 가지지 않으며(`@State` 없음), 외부에서 주입받은 `isSelected` 값에 따라
/// 폰트 굵기, 좌측 아이콘(선택/미선택), 우측 라디오 아이콘, 테두리 색상 등의 UI를 업데이트합니다.
///
/// **사용 예시:**
/// ```swift
/// struct ParentView: View {
///     @State private var selectedOption = "음식점"
///
///     var body: some View {
///         RadioButtonView(
///             unselectedLeftImage: .restaurantUnselected,
///             selectedLeftImage: .restaurantSelected,
///             label: "음식점",
///             isSelected: selectedOption == "음식점",
///             action: {
///                 // 탭 되었을 때 부모 뷰의 상태를 업데이트합니다.
///                 selectedOption = "음식점"
///                 print("음식점 버튼 탭")
///             }
///         )
///     }
/// }
/// ```
struct RadioButtonView: View {
    
    // MARK: - Properties
    private let unselectedLeftImage: UIImage?
    private let selectedLeftImage: UIImage?
    private let label: String
    private let isSelected: Bool
    private let action: () -> Void
    
    // MARK: - Initializer
    
    /// 새로운 `RadioButtonView`를 생성합니다.
    /// - Parameters:
    ///   - unselectedLeftImage: 버튼이 선택되지 않았을 때 좌측에 표시될 옵셔널 이미지입니다. (기본값 `nil`)
    ///   - selectedLeftImage: 버튼이 선택되었을 때 좌측에 표시될 옵셔널 이미지입니다. (기본값 `nil`)
    ///   - label: 라디오 버튼에 표시될 텍스트입니다.
    ///   - isSelected: 버튼의 선택 여부를 결정하는 불리언 값입니다. `true`일 경우 선택 상태 UI가 표시됩니다. 기본값은 `false`입니다.
    ///   - action: 버튼이 탭 되었을 때 실행될 클로저입니다. 이 클로저 내부에서 부모 뷰의 상태 값을 변경해야 합니다.
    init(
        unselectedLeftImage: UIImage? = nil,
        selectedLeftImage: UIImage? = nil,
        label: String,
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.unselectedLeftImage = unselectedLeftImage
        self.selectedLeftImage = selectedLeftImage
        self.label = label
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Content
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isSelected {
                    if let selectedLeftImage {
                        Image(uiImage: selectedLeftImage)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                } else {
                    if let unselectedLeftImage {
                        Image(uiImage: unselectedLeftImage)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                Text(label)
                    .font(isSelected ? .headBold(16) : .bodyMedium(16))
                    .foregroundStyle(isSelected ? .accent : .gray900)
                
                Spacer()
                
                if isSelected {
                    Image(.radioSelected)
                } else {
                    Image(.radioUnselected)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .accent : .gray400,
                        lineWidth: isSelected ? 2 : 1)
        )
        .frame(height: 48)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        // 미선택 상태
        RadioButtonView(
            unselectedLeftImage: .restaurantUnselected,
            selectedLeftImage: .restaurantSelected,
            label: "음식점",
            isSelected: false,
        )
        
        // 선택 상태
        RadioButtonView(
            unselectedLeftImage: .cafeUnselected,
            selectedLeftImage: .cafeSelected,
            label: "카페",
            isSelected: true,
        )
    }
    .padding()
}
