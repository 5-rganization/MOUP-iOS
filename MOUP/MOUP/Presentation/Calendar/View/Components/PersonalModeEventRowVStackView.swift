//
//  PersonalModeEventRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI(개인 캘린더 모드)
final class PersonalModeEventRowVStackView: BaseEventRowVStackView {
    
    // MARK: - Internal Methods
    override func update(event: CalendarEvent) {
        setGivenLabelColor(event.labelColor)
        
        if let workHour = DateFormatter.calculateWorkHour(startTime: event.startTime, endTime: event.endTime, restTime: event.restTime) {
            titleLabel.text = "\(workHour.str)시간"
        } else {
            assertionFailure("calculateWorkHour() 메서드 실행 실패 - Argument가 올바르지 않습니다.")
        }
        
        switch event.salaryCalculation {
        case .hourly:
            // 시급
            dailyIncomeLabel.text = NumberFormatter.decimalFormatter.string(for: event.dailyIncome)
        case .fixed:
            // 고정급
            dailyIncomeLabel.text = event.salaryCalculation.rawValue
        }
        // TODO: 사장님 역할일 때 dailyIncomeLabel 숨김
        dailyIncomeLabel.isHidden = false
    }
    
    func reduceSize() {
        dailyIncomeLabel.isHidden = true
    }
}
