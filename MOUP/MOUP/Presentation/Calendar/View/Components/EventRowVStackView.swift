//
//  EventRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI
final class EventRowVStackView: UIStackView {
    
    // MARK: - UI Components
    /// 근무 시간 라벨
    private let workHourLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textAlignment = .left
    }
    /// 근무자 이름 라벨
    private let workerNameLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textAlignment = .left
    }
    /// 일급 라벨
    private let dailyIncomeLabel = UILabel().then {
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
    func update(calendarMode: CalendarMode, event: CalendarEvent) {
        guard let workHour = DateFormatter.calculateWorkHour(startTime: event.startTime, endTime: event.endTime, restTime: event.restTime) else {
            assertionFailure("calculateWorkHour() 메서드 실행 실패 - Argument 값이 올바르지 않습니다.")
            return
        }
        
        switch calendarMode {
        case .personal:
            workHourLabel.text = workHour.str + "시간"
            workHourLabel.isHidden = false
            workerNameLabel.isHidden = true
            
            setUserLabelColor(event.labelColor)
            
            switch event.salaryCalculation {
            case .hourly:
                // 시급
                dailyIncomeLabel.text = NumberFormatter.decimalFormatter.string(for: event.dailyIncome)
            case .fixed:
                // 고정급
                dailyIncomeLabel.text = "고정급"
            }
            dailyIncomeLabel.isHidden = false
            // TODO: 사장님 개인 캘린더
        case .shared:
            workerNameLabel.text = event.workerName
            workerNameLabel.isHidden = false
            workHourLabel.isHidden = true
            dailyIncomeLabel.isHidden = true
            
            // TODO: 실제 로그인한 사용자의 ID를 반영해야 함
            // 사용자의 workerId가 789임을 가정
            if event.workerId == 789 {
                setUserLabelColor(event.labelColor)
            } else {
                setOtherLabelColor()
            }
        }
    }
}

private extension EventRowVStackView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addArrangedSubviews(workHourLabel,
                                 workerNameLabel,
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
        workHourLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        workerNameLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        dailyIncomeLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
}

// MARK: - Private Methods
private extension EventRowVStackView {
    /// 사용자의 근무에 라벨 컬러를 설정하는 메서드
    func setUserLabelColor(_ labelColor: String) {
        guard let labelColor = LabelColorString(rawValue: labelColor) else {
            assertionFailure("setUserLabelColor() 메서드 실행 실패) labelColor 값이 올바르지 않습니다.")
            return
        }
        self.backgroundColor = labelColor.backgroundColor
        workHourLabel.textColor = labelColor.textColor
        workerNameLabel.textColor = labelColor.textColor
        dailyIncomeLabel.textColor = labelColor.textColor
    }
    
    /// 다른 근무자의 근무에 라벨 컬러를 설정하는 메서드
    func setOtherLabelColor() {
        // TODO: - 사장님 역할일 때 색상 처리 필요
        self.backgroundColor = .primary100
        workHourLabel.textColor = .primary600
        workerNameLabel.textColor = .primary600
        dailyIncomeLabel.textColor = .primary600
    }
}
