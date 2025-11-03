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
    override func update(work: WorkSummary) {
        switch UserRole(rawValue: UserDefaultsManager.shared.userRole ?? UserRole.worker.rawValue)  {
        case .worker:
            setGivenLabelColor(work.workerSummary.workerBasedLabelColorStr ?? LabelColorString._default.rawValue)
            dailyIncomeLabel.isHidden = false
        case .owner:
            setGivenLabelColor(work.workerSummary.ownerBasedLabelColorStr ?? LabelColorString._default.rawValue)
            dailyIncomeLabel.isHidden = true
        default:
            setGivenLabelColor(LabelColorString._default.rawValue)
            dailyIncomeLabel.isHidden = true
        }
        
        titleLabel.text = work.workplaceSummary.name
        sharedChipLabel.isHidden = !work.workplaceSummary.isShared
        
        setTimeInfoUI(startTime: work.startTime, endTime: work.endTime, workMinutes: work.workMinutes)
        
        if let dailyIncome = work.estimatedNetIncome {
            // 시급
            dailyIncomeLabel.text = NumberFormatter.formattedWon(from: dailyIncome)
        } else {
            // 고정급
            dailyIncomeLabel.text = SalaryCalculation.fixed.displayStr
        }
    }
}
