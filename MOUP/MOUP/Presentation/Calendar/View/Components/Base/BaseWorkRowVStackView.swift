//
//  BaseWorkRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI의 부모 `class`
class BaseWorkRowVStackView: UIStackView {
    
    // MARK: - UI Components
    /// 근무 시간 or 근무자 이름 라벨
    let titleLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textAlignment = .left
    }
    /// 일급 라벨
    let dailyIncomeLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textAlignment = .left
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Override Methods
    func update(work: WorkSummary) {
        fatalError("\(#function) 실행 실패 - 메서드가 오버라이딩 되지 않았습니다.")
    }
}

private extension BaseWorkRowVStackView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addArrangedSubviews(titleLabel,
                                 dailyIncomeLabel)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.axis = .vertical
        self.spacing = 0
        self.layoutMargins = .init(top: 0, left: 2, bottom: 0, right: 0)
        self.isLayoutMarginsRelativeArrangement = true
        self.layer.cornerRadius = 4
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(WorkRowSize.baseComponentHeight)
        }
        
        dailyIncomeLabel.snp.makeConstraints {
            $0.height.equalTo(WorkRowSize.baseComponentHeight)
        }
    }
}

// MARK: - Internal Methods
extension BaseWorkRowVStackView {
    /// 설정된 라벨 컬러를 적용하는 메서드
    func setGivenLabelColor(_ labelColorStr: String) {
        guard let labelColor = LabelColorString(rawValue: labelColorStr) else {
            assertionFailure("\(#function) 실행 실패 - labelColorStr 값이 올바르지 않습니다.")
            return
        }
        self.backgroundColor = labelColor.backgroundColor
        titleLabel.textColor = labelColor.textColor
        dailyIncomeLabel.textColor = labelColor.textColor
    }
    
    /// 기본 라벨 컬러를 적용하는 메서드
    func setDefaultLabelColor() {
        self.backgroundColor = .primary100
        titleLabel.textColor = .primary600
        dailyIncomeLabel.textColor = .primary600
    }
}
