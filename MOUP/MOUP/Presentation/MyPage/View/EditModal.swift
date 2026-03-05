//
//  EditModal.swift
//  MOUP
//
//  Created by shinyoungkim on 8/11/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class EditModal: UIView {
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = .headBold(18)
        $0.setLineSpacing(.headBold)
        $0.textColor = .gray900
    }
    
    fileprivate let textField = OLDCustomTextField().then {
        $0.placeholder = "닉네임을 입력해주세요"
    }
    
    private let validationLabel = UILabel().then {
        $0.font = .fieldsRegular(12)
        $0.setLineSpacing(.fieldsRegular)
        $0.textColor = .gray700
        $0.text = "특수문자 제외 8자 이하로 입력해주세요"
    }
    
    fileprivate let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.gray500, for: .normal)
        $0.backgroundColor = .gray300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func focusTextField() {
        textField.becomeFirstResponder()
    }
    
    func updateValidationLabel(
        state: ValidationViewState,
        isEnabled: Bool
    ) {
        switch state {
        case .empty(let placeholder):
            validationLabel.text = placeholder
            validationLabel.textColor = .gray700
        case .valid(let message):
            validationLabel.text = message
            validationLabel.textColor = .success
        case .invalid(let message):
            validationLabel.text = message
            validationLabel.textColor = .fail
        }
        
        saveButton.isEnabled = isEnabled
        if isEnabled {
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.backgroundColor = .primary500
        } else {
            saveButton.setTitleColor(.gray500, for: .normal)
            saveButton.backgroundColor = .gray300
        }
    }
}

private extension EditModal {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            textField,
            validationLabel,
            saveButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        validationLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(8)
            $0.leading.equalTo(textField.snp.leading).offset(8)
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
}

extension Reactive where Base: EditModal {
    var text: ControlProperty<String> {
        base.textField.rx.text.orEmpty
    }
    
    var saveButtonTapped: ControlEvent<Void> {
        base.saveButton.rx.tap
    }
}
