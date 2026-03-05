//
//  LabelChevronRowView.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

/// (색상)-라벨-Chevron-(라벨) Row
///
/// 옵션으로 좌측에 색상을 나타내는 원(`Circle`)을 띄우거나, 우측에 부가적인 텍스트(`rearLabel`)를 배치할 수 있습니다.
/// 뷰 전체가 하나의 버튼으로 동작하므로, 터치 시 `onTapAction` 클로저를 통해 네비게이션 이동 등의 이벤트를 처리하기 좋습니다.
///
/// **사용 예시:**
/// ```swift
/// struct ParentView: View {
///     var body: some View {
///         LabelChevronRowView(
///             color: .systemRed,
///             frontLabel: "루틴 추가",
///             rearLabel: "+ 1",
///             onTapAction: {
///                 // 다른 화면으로 이동하거나 특정 로직을 실행합니다.
///                 print("루틴 추가 Row가 탭 되었습니다!")
///             }
///         )
///     }
/// }
/// ```
struct LabelChevronRowView: View {
    
    // MARK: - Properties
    private let color: UIColor?
    private let frontLabel: String
    private let rearLabel: String?
    private let onTapAction: () -> Void
    
    // MARK: - Initializer
    
    /// 새로운 `LabelChevronRowView`를 생성합니다.
    ///
    /// - Parameters:
    ///   - color: 맨 좌측에 표시될 원형 마커의 색상(`UIColor`)입니다. `nil`일 경우 원이 표시되지 않습니다. 기본값은 `nil`입니다.
    ///   - frontLabel: 좌측에 표시될 메인 텍스트입니다.
    ///   - rearLabel: 우측 꺾쇠 아이콘 바로 앞에 표시될 부가 텍스트입니다. `nil`일 경우 표시되지 않습니다. 기본값은 `nil`입니다.
    ///   - onTapAction: 행(Row) 전체를 탭 했을 때 실행될 액션 클로저입니다.
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
                    .foregroundStyle(.gray900)
                
                Spacer()
                
                if let rearLabel {
                    Text(rearLabel)
                        .font(.fieldsRegular(16))
                        .foregroundStyle(.gray900)
                }
                Image(.chevronRight)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .frame(height: 48)
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        // 색상과 부가 라벨이 모두 있는 경우
        LabelChevronRowView(
            color: .labelRed,
            frontLabel: "빨간색"
        )
        
        // 메인 라벨만 있는 경우
        LabelChevronRowView(
            frontLabel: "루틴 추가",
            rearLabel: "+ 1"
        )
    }
}
