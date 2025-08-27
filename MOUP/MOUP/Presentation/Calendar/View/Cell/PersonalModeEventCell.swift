//
//  PersonalModeEventCell.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// 근무 목록 셀(개인 캘린더 모드)
final class PersonalModeEventCell: BaseEventCell {
    
    // MARK: - Properties
    static let identifier = String(describing: PersonalModeEventCell.self)
    
    // MARK: - Internal Methods
    override func update(event: CalendarEvent) {
        setGivenLabelColor(event.labelColor)
        
        titleLabel.text = event.workplaceName
        sharedChipLabel.isHidden = !event.isShared
        
        setTimeInfoUI(startTime: event.startTime, endTime: event.endTime, restTime: event.restTime)
        
        // TODO: 사장님 역할일 때 dailyIncomeLabel 숨김
        dailyIncomeLabel.isHidden = false
        switch event.salaryCalculation {
        case .hourly:
            dailyIncomeLabel.text = "\(NumberFormatter.formattedWon(from: event.dailyIncome))"
        case .fixed:
            dailyIncomeLabel.text = SalaryCalculation.fixed.rawValue
        }
    }
}
