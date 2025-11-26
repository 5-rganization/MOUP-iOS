//
//  NicknameView.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit
import OSLog

import RxSwift
import RxCocoa
import SnapKit
import Then

final class NicknameView: UIView {
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    fileprivate let navigationBar = BaseNavigationBar(title: "닉네임 설정").then {
        $0.configureBackButton(isHidden: true)
    }
    
    private let defaultNoticeAttributedString: NSAttributedString = {
        let fullText = """
            1~8자 한글·영문·숫자 사용가능
            한글·영문 혼용, 띄어쓰기, 특수문자 사용 불가
            """
        
        var attributedString = AttributedString(fullText)
        attributedString.font = .fieldsRegular(12)
        attributedString.foregroundColor = .gray700
        
        return NSAttributedString(attributedString)
    }()
    
    // MARK: - UI Components
    private let nicknameTitleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.text = "닉네임을 설정해주세요"
        $0.textColor = .gray900
    }
    
    fileprivate let nicknameTextField = UITextField().then {
        let attributedPlaceholder = NSAttributedString(string: "닉네임을 입력해주세요.", attributes: [.foregroundColor: UIColor.gray400])
        $0.attributedPlaceholder = attributedPlaceholder
        
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        
        $0.textColor = .gray900
        $0.font = .fieldsRegular(16)
        
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 36))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 36))
        $0.rightViewMode = .always
    }
    
    private lazy var noticeLabel = UILabel().then {
        $0.font = .fieldsRegular(12)
        $0.numberOfLines = 0
        $0.attributedText = defaultNoticeAttributedString
        $0.setLineSpacing(.fieldsRegular)
    }
    
    fileprivate let startButton = BaseButton(title: "다음").then {
        $0.isEnabled = false
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
    func update(isValid: Bool) {
        if let nicknameText = nicknameTextField.text, nicknameText.isEmpty {
            noticeLabel.attributedText = defaultNoticeAttributedString
            startButton.isEnabled = false
        } else {
            let attributedText = NSAttributedString(
                string: isValid ? "사용 가능한 닉네임이에요!" : "특수문자 제외 8자 이하로 입력해주세요",
                attributes: [.font: UIFont.fieldsRegular(12), .foregroundColor : isValid ? UIColor.success : UIColor.fail]
            )
            noticeLabel.attributedText = attributedText
            startButton.isEnabled = isValid
        }
        noticeLabel.setLineSpacing(.fieldsRegular)
    }
}

private extension NicknameView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            nicknameTitleLabel,
            nicknameTextField,
            noticeLabel,
            startButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        nicknameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).inset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameTitleLabel.snp.bottom).offset(22)
            $0.directionalHorizontalEdges.equalTo(nicknameTitleLabel)
            $0.height.equalTo(48)
        }
        
        noticeLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.directionalHorizontalEdges.equalTo(nicknameTitleLabel)
        }
        
        startButton.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalTo(nicknameTitleLabel)
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-12)
            $0.height.equalTo(44)
        }
    }
}

extension Reactive where Base: NicknameView {
    var nicknameText: ControlProperty<String> {
        return base.nicknameTextField.rx.text.orEmpty
    }
    
    var startButtonTap: ControlEvent<Void> {
        return base.startButton.rx.tap
    }
}
