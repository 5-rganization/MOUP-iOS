//
//  AddRoutineView.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import UIKit
import Then
import SnapKit

final class AddRoutineView: UIView {

    // MARK: - UI Components
    
    private let navigationBar = BaseNavigationBar(title: "새 루틴").then {
        $0.configureRightButton(icon: nil, title: "저장")
    }
    
    private let routineTitleLabel = UILabel().then {
        $0.text = "제목"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    
    private let textfield = CustomTextField().then {
        let placeholderText = "제목을 입력해 주세요"
        $0.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .foregroundColor: UIColor.gray400,
                .font: UIFont.fieldsRegular(16)
            ]
        )
    }
    
    private let alarmTimeButton = UIButton(configuration: .filled()).then {
        var config = $0.configuration
        config?.title = "알림시간"
        config?.baseForegroundColor = .gray900
        config?.baseBackgroundColor = .clear
        config?.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )
        var container = AttributeContainer()
        container.font = UIFont.bodyMedium(16)
        config?.attributedTitle = AttributedString(
            "알림시간", attributes: container
        )
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.clipsToBounds = true
    }
    
    private let todoListTitleLabel = UILabel().then {
        $0.text = "할 일 리스트"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    
    private let addTodoButton = UIButton().then {
        $0.setImage(.plus, for: .normal)
    }
    
    private let todoListStackView = UIStackView().then {
        $0.axis = .vertical
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AddRoutineView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            routineTitleLabel,
            textfield,
            alarmTimeButton,
            todoListTitleLabel,
            addTodoButton,
            todoListStackView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        routineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        textfield.snp.makeConstraints {
            $0.top.equalTo(routineTitleLabel.snp.bottom).offset(18)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        alarmTimeButton.snp.makeConstraints {
            $0.top.equalTo(textfield.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        todoListTitleLabel.snp.makeConstraints {
            $0.top.equalTo(alarmTimeButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        
        addTodoButton.snp.makeConstraints {
            $0.centerY.equalTo(todoListTitleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        todoListStackView.snp.makeConstraints {
            $0.top.equalTo(todoListTitleLabel.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        addTodoButton.addTarget(
            self,
            action: #selector(addTodoDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func addTodoDidTap() {
        let todoTextField = UITextField().then {
            let placeholder = "할 일"
            $0.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.gray400,
                    .font: UIFont.fieldsRegular(16)
                ]
            )
            $0.font = .bodyMedium(14)
        }
        
        todoTextField.snp.makeConstraints {
            $0.height.equalTo(45)
        }
        
        todoListStackView.addArrangedSubview(todoTextField)
        
        todoTextField.becomeFirstResponder()
    }
}
