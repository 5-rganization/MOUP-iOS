//
//  PersonalModeWorkCell.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// 근무 목록 셀(개인 캘린더 모드)
final class PersonalModeWorkCell: BaseWorkCell {
    
    // MARK: - Properties
    static let identifier = String(describing: PersonalModeWorkCell.self)
    
    // MARK: - Internal Methods
    override func update(work: CalendarWork) {
        setGivenLabelColor(work.labelColor)
        
        titleLabel.text = work.workplaceName
        sharedChipLabel.isHidden = !work.isShared
        
        setTimeInfoUI(startTime: work.startTime, endTime: work.endTime, restTime: work.restTime)
        
        // TODO: 사장님 역할일 때 dailyIncomeLabel 숨김
        dailyIncomeLabel.isHidden = false
        switch work.salaryCalculation {
        case .hourly:
            dailyIncomeLabel.text = "\(NumberFormatter.formattedWon(from: work.dailyIncome))"
        case .fixed:
            dailyIncomeLabel.text = SalaryCalculation.fixed.rawValue
        }
    }
}
