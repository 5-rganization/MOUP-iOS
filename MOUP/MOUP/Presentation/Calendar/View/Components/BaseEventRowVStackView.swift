//
//  BaseEventRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI의 부모 클래스
class BaseEventRowVStackView: UIStackView {
    
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
    
    // MARK: - Internal Methods
    func update(event: CalendarEvent) {
        fatalError("update() 메서드 실행 실패 - 메서드가 오버라이딩 되지 않았습니다.")
    }
}

private extension BaseEventRowVStackView {
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
            $0.height.equalTo(18)
        }
        
        dailyIncomeLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
}

// MARK: - Methods
extension BaseEventRowVStackView {
    /// 사용자의 근무에 라벨 컬러를 설정하는 메서드
    func setUserLabelColor(_ labelColor: String) {
        guard let labelColor = LabelColorString(rawValue: labelColor) else {
            assertionFailure("setUserLabelColor() 메서드 실행 실패 - labelColor 값이 올바르지 않습니다.")
            return
        }
        self.backgroundColor = labelColor.backgroundColor
        titleLabel.textColor = labelColor.textColor
        dailyIncomeLabel.textColor = labelColor.textColor
    }
    
    /// 다른 근무자의 근무에 라벨 컬러를 설정하는 메서드
    func setOtherLabelColor() {
        // TODO: - 사장님 역할일 때 색상 처리 필요
        self.backgroundColor = .primary100
        titleLabel.textColor = .primary600
        dailyIncomeLabel.textColor = .primary600
    }
}
