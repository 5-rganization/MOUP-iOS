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
        isLoading = true
        self.isEnabled = false
    }
    
    /// API 응답 후 로딩 상태를 종료합니다. (인디케이터 숨김, 터치 활성화)
    func stopLoading() {
        isLoading = false
        self.isEnabled = true
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
        config.background.cornerRadius = 12
        
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
