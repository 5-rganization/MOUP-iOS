//
//  PersonalModeWorkRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI(개인 캘린더 모드)
final class PersonalModeWorkRowVStackView: BaseWorkRowVStackView {
    
    // MARK: - Internal Methods
    override func update(work: WorkSummary) {
        switch UserRole(rawValue: UserDefaultsManager.shared.userRole ?? UserRole.worker.rawValue) {
        case .worker:
            setGivenLabelColor(work.workerSummary.workerBasedLabelColorStr ?? LabelColor._default.serverStr)
            dailyIncomeLabel.isHidden = false
        case .owner:
            setGivenLabelColor(work.workerSummary.ownerBasedLabelColorStr ?? LabelColor._default.serverStr)
            dailyIncomeLabel.isHidden = true
        default:
            setGivenLabelColor(LabelColor._default.serverStr)
            dailyIncomeLabel.isHidden = true
        }
        
        
        titleLabel.text = "\(work.workMinutes.decimalTimeString)"
        
        if let dailyIncome = work.estimatedNetIncome {
            // 시급
            dailyIncomeLabel.text = NumberFormatter.decimalFormatter.string(for: dailyIncome)
        } else {
            // 고정급
            dailyIncomeLabel.text = SalaryCalculation.fixed.displayStr
        }
    }
    
    func reduceSize() {
        dailyIncomeLabel.isHidden = true
    }
}
