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
        guard let borderColor = LabelColorString(rawValue: event.labelColor) else {
            assertionFailure("LabelColorString 변환 실패 - labelColor 값이 올바르지 않습니다.")
            return
        }
        labelColorBorderView.update(borderColor: borderColor)
        
        titleLabel.text = event.workplaceName
        sharedChipLabel.isHidden = !event.isShared
        
        guard let workHour = DateFormatter.calculateWorkHour(startTime: event.startTime, endTime: event.endTime, restTime: event.restTime) else {
            assertionFailure("calculateWorkHour() 메서드 실행 실패 - Argument가 올바르지 않습니다.")
            return
        }
        if workHour.minutesInt == 0 {
            workHourLabel.text = "\(event.startTime) ~ \(event.endTime) (\(workHour.hoursInt)시간)"
        } else {
            workHourLabel.text = "\(event.startTime) ~ \(event.endTime) (\(workHour.hoursInt)시간 \(workHour.minutesInt)분)"
        }
        
        dailyIncomeLabel.isHidden = false
        switch event.salaryCalculation {
        case .hourly:
            let formatted = NumberFormatter.formattedWon(from: event.dailyIncome)
            dailyIncomeLabel.text = "\(formatted)"
        case .fixed:
            dailyIncomeLabel.text = SalaryCalculation.fixed.rawValue
        }
    }
}
