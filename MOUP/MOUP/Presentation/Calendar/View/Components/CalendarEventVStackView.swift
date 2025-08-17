//
//  CalendarEventVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI
final class CalendarEventVStackView: UIStackView {
    
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
        guard let (workHourDecimal, workHourStr) = DateFormatter.workHourDecimal(startTime: event.startTime, endTime: event.endTime, restTime: event.restTime) else { return }
        if calendarMode == .shared {
            workerNameLabel.text = event.workerName
            workerNameLabel.isHidden = false
            workHourLabel.isHidden = true
            dailyIncomeLabel.isHidden = true
        } else {
            workHourLabel.text = "\(workHourStr)시간"
            workHourLabel.isHidden = false
            workerNameLabel.isHidden = true
            
            switch event.salaryCalculation {
            case .hourly:
                // 시급
                dailyIncomeLabel.text = NumberFormatter.decimalFormatter.string(for: Int(event.dailyIncome))
                dailyIncomeLabel.isHidden = false
            case .fixed:
                // 고정급
                dailyIncomeLabel.text = "고정급"
                dailyIncomeLabel.isHidden = false
            }
            // TODO: 사장님 개인 캘린더
        }
        
        // TODO: 개인 캘린더 모드일 때 자신의 근무가 아니면 primaryColor 처리 필요
        if let labelColor = LabelColorString(rawValue: event.labelColor) {
            self.backgroundColor = labelColor.backgroundColor
            workHourLabel.textColor = labelColor.textColor
            workerNameLabel.textColor = labelColor.textColor
            dailyIncomeLabel.textColor = labelColor.textColor
        } else {
            self.backgroundColor = .primary100
            workHourLabel.textColor = .primary600
            workerNameLabel.textColor = .primary600
            dailyIncomeLabel.textColor = .primary600
        }
    }
}

private extension CalendarEventVStackView {
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
