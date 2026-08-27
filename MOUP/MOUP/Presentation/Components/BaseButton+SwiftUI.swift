//
//  BaseButton.swift
//  MOUP
//
//  Created by 서동환 on 7/23/25.
//

import UIKit

/// 메인 버튼
final class BaseButton: UIButton {
    
    // MARK: - Properties
    private var isLoading: Bool = false
    
    // MARK: - Initializer
    init(title: String = "적용하기", isSecondary: Bool = false, fontSize: CGFloat = 18) {
        super.init(frame: .zero)
        configure(title: title, isSecondary: isSecondary, fontSize: fontSize)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Internal Methods
    func update(title: String, isSecondary: Bool = false, fontSize: CGFloat = 18) {
        setConfiguration(title: title, isSecondary: isSecondary, fontSize: fontSize)
    }
    
    /// API 호출 전 로딩 상태를 시작합니다. (인디케이터 표시, 터치 비활성화)
    func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.isEnabled = false
        }
    }
    
    /// API 응답 후 로딩 상태를 종료합니다. (인디케이터 숨김, 터치 활성화)
    func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.isEnabled = true
        }
    }
}

private extension BaseButton {
    // MARK: - configure
    func configure(title: String, isSecondary: Bool, fontSize: CGFloat = 18) {
        setStyles(title: title, isSecondary: isSecondary, fontSize: fontSize)
    }
    
    // MARK: - setStyles
    func setStyles(title: String, isSecondary: Bool, fontSize: CGFloat = 18) {
        setConfiguration(title: title, isSecondary: isSecondary, fontSize: fontSize)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
    }
    
    // MARK: - setConfiguration
    func setConfiguration(title: String, isSecondary: Bool, fontSize: CGFloat) {
        let normalAttribute = AttributeContainer([.font: UIFont.buttonSemibold(fontSize),
                                                  .foregroundColor: isSecondary ? UIColor.gray600 : UIColor.white])
        let disableAttribute = AttributeContainer([.font: UIFont.buttonSemibold(fontSize),
                                                   .foregroundColor: UIColor.gray500])
        let baseBackgroundColor: UIColor = isSecondary ? .gray200 : .accent
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: normalAttribute)
        config.imagePadding = 8
        config.baseBackgroundColor = baseBackgroundColor
        config.background.cornerRadius = 12  // iOS 26에서 UIButton.Configuration의 cornerRadius가 적용되지 않는 문제에 대한 workaround
        
        let handler: UIButton.ConfigurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            
            button.configuration?.showsActivityIndicator = isLoading
            
            switch button.state {
            case .normal:
                button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                button.configuration?.baseBackgroundColor = baseBackgroundColor
            case .highlighted:
                button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                button.configuration?.baseBackgroundColor = baseBackgroundColor
            case .disabled:
                if isLoading {
                    button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                    button.configuration?.baseBackgroundColor = baseBackgroundColor
                } else {
                    button.configuration?.attributedTitle = AttributedString(title, attributes: disableAttribute)
                    button.configuration?.baseBackgroundColor = .gray300
                }
            default:
                button.configuration?.attributedTitle = AttributedString(title, attributes: normalAttribute)
                button.configuration?.baseBackgroundColor = .accent
            }
        }
        
        self.configuration = config
        self.configurationUpdateHandler = handler
    }
}

// MARK: - SwiftUI Convert

import SwiftUI

/// `BaseButton`의 SwiftUI 래퍼
/// - 높이 45 지정되어있음
///
/// **사용 예시**
/// ```swift
/// HStack(spacing: 12) {
///     BaseButtonSU(title: "취소", isSecondary: true) {
///         // 취소 액션
///     }
///     .frame(height: 45)
///
///     BaseButtonSU(title: "선택") {
///         // 확인 액션
///     }
///     .frame(height: 45)
/// }
/// ```
struct BaseButtonSU: UIViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    var isSecondary: Bool = false
    var fontSize: CGFloat = 18
    var action: () -> Void

    func makeUIView(context: Context) -> BaseButton {
        let button = BaseButton(title: title, isSecondary: isSecondary, fontSize: fontSize)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: BaseButton, context: Context) {
        uiView.update(title: title, isSecondary: isSecondary, fontSize: fontSize)
        uiView.isEnabled = isEnabled
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: BaseButton, context: Context) -> CGSize? {
        let width = proposal.width ?? UIApplication.screenWidth
        return CGSize(width: width, height: 45)
    }
}
