//
//  WizardTextFieldView.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

/// 텍스트 입력 필드 (내부 네비게이션에서 사용)
///
/// 내부적으로 `@Binding`을 사용하여 부모 뷰와 텍스트 상태를 양방향으로 공유하며,
/// 지정된 정규표현식(Regex)을 활용하여 허용되지 않은 문자(예: 문자, 기호) 입력을 차단합니다.
///
/// **사용 예시 1: 일반 텍스트 입력**
/// ```swift
/// struct ParentView: View {
///     @State private var workplaceName = ""
///
///     var body: some View {
///         WizardTextFieldView(
///             placeholder: "근무지 이름",
///             text: $workplaceName
///         )
///     }
/// }
/// ```
///
/// **사용 예시 2: 금액 포매팅 (커스텀 바인딩 및 정규식 활용)**
/// 부모 뷰는 순수 정수(`Int`)를 관리하고, 화면에는 콤마와 단위를 표시할 때 커스텀 바인딩을 사용합니다.
/// ```swift
/// struct SalaryInputView: View {
///     @State private var salary = 15000
///
///     var body: some View {
///         WizardTextFieldView(
///             placeholder: "10,320원",
///             text: Binding<String>(
///                 get: {
///                     // 부모 뷰의 순수 데이터를 포매팅하여 텍스트 필드에 표시
///                     NumberFormatter.formattedWon(from: salary)
///                 },
///                 set: { newValue in
///                     // 사용자가 입력한 값에서 숫자만 필터링하여 부모 변수에 저장
///                     let numbersOnly = newValue.filter { $0.isNumber }
///                     if let intValue = Int(numbersOnly) {
///                         salary = intValue
///                     }
///                 }
///             ),
///             keyboardType: .numberPad,
///             // 숫자, 콤마(,), '원' 글자만 입력 가능하도록 정규식 제한
///             regexStr: "^[0-9,원]*$"
///         )
///     }
/// }
/// ```
struct WizardTextFieldView: View {
    
    // MARK: - Properties
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let regex: Regex<AnyRegexOutput>?
    
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    @State private var lastValidText: String = ""
    
    // MARK: - Initializer
    
    /// 새로운 `WizardTextFieldView`를 생성합니다.
    ///
    /// - Parameters:
    ///   - placeholder: 입력값이 없을 때 표시될 안내 문구입니다.
    ///   - text: 부모 뷰와 연결된 문자열 바인딩(`@Binding`)입니다.
    ///   - keyboardType: 텍스트 필드 포커스 시 표시될 키보드 타입입니다. 기본값은 `.default`입니다.
    ///   - regex: 입력값을 제한할 정규표현식 문자열입니다. 기본값은 `nil`입니다.
    init(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        regexStr: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        if let regexStr {
            self.regex = try? Regex(regexStr)
            assert(self.regex != nil, "올바르지 않은 정규표현식: \(regexStr)")
        } else {
            self.regex = nil
        }
        
        self._lastValidText = State(initialValue: text.wrappedValue)
    }
    
    // MARK: - Content
    var body: some View {
        HStack {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(.fieldsRegular(16))
                    .foregroundColor(.gray400) // Deprecated 예정, iOS 17부터 foregroundStyle로 변경
            )
            .font(.fieldsRegular(16))
            .foregroundStyle(.gray900)
            .focused($isFocused)
            .lineLimit(1)
            .keyboardType(keyboardType)
            .onChange(of: text) { newValue in // Deprecated 예정, iOS 17부터 onChange(of:initial:_:)로 변경
                guard !newValue.isEmpty else {
                    lastValidText = newValue
                    return
                }
                
                // 정규표현식 검사
                if let regex {
                    guard newValue.wholeMatch(of: regex) != nil else {
                        text = lastValidText
                        return
                    }
                }
                
                lastValidText = newValue
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray400, lineWidth: 1)
        )
    }
}

// MARK: - Preview
private struct WizardTextFieldPreviewWrapper: View {
    @State private var workplaceName = ""
    @State private var salary = 15000
    
    var body: some View {
        VStack(spacing: 12) {
            WizardTextFieldView(
                placeholder: "근무지 이름",
                text: $workplaceName
            )
            
            WizardTextFieldView(
                placeholder: "10,320원",
                text: Binding<String>(
                    get: {
                        NumberFormatter.formattedWon(from: salary)
                    },
                    set: { newValue in
                        let numbersOnly = newValue.filter { $0.isNumber }
                        if let intValue = Int(numbersOnly) {
                            salary = intValue
                        }
                    }
                ),
                keyboardType: .numberPad,
                regexStr: "^[0-9,원]*$"
            )
            
            Text("부모 뷰가 가진 원본 데이터: \(salary)")
        }
        .padding()
    }
}

#Preview {
    WizardTextFieldPreviewWrapper()
}
