//
//  LabelChevronRowView.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

/// (색상)-라벨-Chevron-(라벨) Row
///
/// 옵션으로 좌측에 색상을 나타내는 원(`leftColor`)을 띄우거나, 우측에 부가적인 텍스트(`rightLabel`)를 배치할 수 있습니다.
/// 뷰 전체가 하나의 버튼으로 동작하므로, 터치 시 `action` 클로저를 통해 네비게이션 이동 등의 이벤트를 처리하기 좋습니다.
///
/// **사용 예시:**
/// ```swift
/// struct ParentView: View {
///     var body: some View {
///         LabelChevronRowView(
///             titleLabel: "루틴 추가",
///             rightLabel: "+ 1",
///             action: {
///                 // 다른 화면으로 이동하거나 특정 로직을 실행합니다.
///                 print("루틴 추가 Row 탭")
///             }
///         )
///     }
/// }
/// ```
struct LabelChevronRowView: View {
    
    // MARK: - Properties

    /// 비활성화 상태에서는 이동 불가이므로 꺾쇠를 숨긴다.
    @Environment(\.isEnabled) private var isEnabled

    private let leftColor: UIColor?
    private let titleLabel: String
    private let rightLabel: String?
    private let action: () -> Void
    
    // MARK: - Initializer
    
    /// 새로운 `LabelChevronRowView`를 생성합니다.
    ///
    /// - Parameters:
    ///   - leftColor: 맨 좌측에 표시될 원형 마커의 색상(`UIColor`)입니다. `nil`일 경우 원이 표시되지 않습니다. 기본값은 `nil`입니다.
    ///   - titleLabel: 좌측에 표시될 메인 텍스트입니다.
    ///   - rightLabel: 우측 꺾쇠 아이콘 바로 앞에 표시될 부가 텍스트입니다. `nil`일 경우 표시되지 않습니다. 기본값은 `nil`입니다.
    ///   - action: 행(Row) 전체를 탭 했을 때 실행될 액션 클로저입니다.
    init(
        leftColor: UIColor? = nil,
        titleLabel: String,
        rightLabel: String? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.leftColor = leftColor
        self.titleLabel = titleLabel
        self.rightLabel = rightLabel
        self.action = action
    }
    
    // MARK: - Content
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let leftColor {
                    Circle()
                        .fill(Color(uiColor: leftColor))
                        .frame(width: 12, height: 12)
                }
                Text(titleLabel)
                    .font(.bodyMedium(16))
                    .foregroundStyle(.gray900)
                
                Spacer()
                
                if let rightLabel {
                    Text(rightLabel)
                        .font(.fieldsRegular(16))
                        .foregroundStyle(.gray900)
                }
                if isEnabled {
                    Image(.chevronRight)
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
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        // 색상과 메인 라벨이 있는 경우
        LabelChevronRowView(
            leftColor: .labelRed,
            titleLabel: "빨간색"
        )
        
        // 메인 라벨과 우측 라벨이 있는 경우
        LabelChevronRowView(
            titleLabel: "루틴 추가",
            rightLabel: "+ 1"
        )
    }
}
