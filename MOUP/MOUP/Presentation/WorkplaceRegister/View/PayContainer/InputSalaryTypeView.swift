//
//  InputSalaryTypeView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import SnapKit
import Then

final class InputSalaryTypeView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    private let title = UILabel().then {
        $0.text = "시급을 입력해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
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
}

private extension InputSalaryTypeView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            title
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        title.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
    }
}
