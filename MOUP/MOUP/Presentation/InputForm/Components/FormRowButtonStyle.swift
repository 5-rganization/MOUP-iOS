//
//  FormRowButtonStyle.swift
//  MOUP
//
//  Created by 서동환 on 8/16/26.
//

import SwiftUI

/// 입력 폼 Row 전용 `ButtonStyle`
///
/// `.plain`은 비활성화(`.disabled`) 상태에서 라벨 전체를 흐리게 렌더링해
/// 근무 수정 화면의 잠금 상태에서 입력값이 잘 안 보인다.
/// 각 Row가 `@Environment(\.isEnabled)`로 비활성화 표현을 직접 갖고 있으므로
/// 시스템 디밍 없이 라벨을 그대로 그린다.
struct FormRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
