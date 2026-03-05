//
//  MemoView.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

/// 메모 필드
///
/// 사용자가 긴 문장을 작성할 때 위에서 아래로 늘어나며 입력할 수 있도록 구성되어 있습니다.
/// 내부적으로 최대 150자의 글자 수 제한 기능을 포함하고 있으며, 우측 하단에 글자 수 카운터를 표시합니다.
///
/// **사용 예시:**
/// ```swift
/// struct ParentView: View {
///     @State private var memo = ""
///
///     var body: some View {
///         MemoView(text: $memo)
///     }
/// }
/// ```
struct MemoView: View {
    
    // MARK: - Properties
    private let maxCount = 150
    
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    
    // MARK: - Initializer
    
    /// 새로운 `MemoView`를 생성합니다.
    ///
    /// - Parameter text: 부모 뷰와 연결되어 텍스트를 양방향으로 공유할 문자열 바인딩(`@Binding`)입니다.
    init(text: Binding<String>) {
        self._text = text
    }
    
    // MARK: - Content
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text("추가적인 내용을 입력해주세요")
                .font(.fieldsRegular(16))
                .foregroundColor(.gray400), // Deprecated 예정, iOS 17부터 foregroundStyle로 변경
            axis: .vertical
        )
        .font(.fieldsRegular(16))
        .foregroundStyle(.gray900)
        .setLineSpacing(.fieldsRegular, fontSize: 16)
        .focused($isFocused)
        .frame(minHeight: 156, alignment: .topLeading)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .onChange(of: text) { newValue in // Deprecated 예정, iOS 17부터 onChange(of:initial:_:)로 변경
            guard newValue.count > maxCount else { return }
            text = String(newValue.prefix(maxCount))
        }
        .overlay(alignment: .bottomTrailing) {
            Text("\(text.count)/\(maxCount)")
                .font(.fieldsRegular(16))
                .foregroundColor(.gray600)
                .padding(.bottom, 12)
                .padding(.trailing, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray400, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Preview
private struct MemoPreviewWrapper: View {
    @State private var text1 = ""
    @State private var text2 = "텍스트 입력 상황"
    
    var body: some View {
        VStack(spacing: 12) {
            MemoView(text: $text1)
            MemoView(text: $text2)
        }
        .padding()
    }
}

#Preview {
    MemoPreviewWrapper()
}
