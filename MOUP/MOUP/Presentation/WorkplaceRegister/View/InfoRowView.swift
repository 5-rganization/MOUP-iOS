//
//  InfoRowView.swift
//  MOUP
//
//  Created by 양원식 on 7/18/25.
//
import UIKit
import SnapKit
import Then

enum InfoRowType {
    case checkBox(isChecked: Bool)
    case labelWithChevron(value: String)
    case labelWithButton(title: String)
}


final class InfoRowView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray700
    }
    
    private let chevronButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .gray400
        $0.isUserInteractionEnabled = false
    }
    
    private let checkBox = UIButton().then {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.tintColor = .gray400
    }
    
    private let actionButton = UIButton(configuration: .filled()).then {
        $0.configuration?.baseBackgroundColor = .primary100
        $0.configuration?.baseForegroundColor = .gray700
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private var rowType: InfoRowType?
    
    // MARK: - Initializer
    init(title: String, type: InfoRowType, frame: CGRect) {
        super.init(frame: frame)
        self.rowType = type
        self.titleLabel.text = title
        configure(type: type)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
}

private extension InfoRowView {
    // MARK: - configure
    func configure(type: InfoRowType) {
        setHierarchy(type: type)
        setStyles(type: type)
        setConstraints(type: type)
    }
    
    // MARK: - setHierarchy
    func setHierarchy(type: InfoRowType) {
        addSubviews(
            titleLabel
        )
        
        switch type {
        case .checkBox:
            addSubviews(
                checkBox
            )
        case .labelWithChevron:
            addSubviews(
                valueLabel,
                chevronButton
            )
        case .labelWithButton:
            addSubviews(
                actionButton
            )
        }
    }
    
    // MARK: - setStyles
    func setStyles(type: InfoRowType) {
        switch type {
        case .checkBox(let isChecked):
            checkBox.isSelected = isChecked
        case .labelWithChevron(let value):
            valueLabel.text = value
        case .labelWithButton(let title):
            actionButton.setTitle(title, for: .normal)
        }
    }
    
    // MARK: - setConstraints
    func setConstraints(type: InfoRowType) {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
        }
        
        switch type {
        case .checkBox:
            checkBox.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(12)
            }
            
        case .labelWithChevron:
            valueLabel.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel)
                $0.trailing.equalTo(chevronButton.snp.leading).offset(-12)
            }
            
            chevronButton.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel)
                $0.trailing.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(12)
            }
            
        case .labelWithButton:
            actionButton.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.bottom.equalToSuperview().inset(12)
            }
        }
    }
}

