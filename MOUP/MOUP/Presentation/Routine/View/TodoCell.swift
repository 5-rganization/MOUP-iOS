//
//  TodoCell.swift
//  MOUP
//
//  Created by shinyoungkim on 9/17/25.
//

import UIKit
import Then
import SnapKit

final class TodoCell: UITableViewCell {
    
    static let id = "TodoCell"

    // MARK: - UI Components
    
    private let todoTextField = UITextField().then {
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
    
    private let handleButton = UIButton().then {
        $0.setImage(
            UIImage.line3Horizontal,
            for: .normal
        )
    }
    
    // MARK: - Getter
    
    var textField: UITextField { todoTextField }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TodoCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            todoTextField,
            handleButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        selectionStyle = .none
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        todoTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        handleButton.snp.makeConstraints {
            $0.leading.equalTo(todoTextField.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
    }
}
