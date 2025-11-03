//
//  SharedModeWorkCell.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// 근무 목록 셀(공유 캘린더 모드)
final class SharedModeWorkCell: BaseWorkCell {
    
    // MARK: - Properties
    static let identifier = String(describing: SharedModeWorkCell.self)
    
    // MARK: - Internal Methods
    override func update(work: WorkSummary) {
        switch UserRole(rawValue: UserDefaultsManager.shared.userRole ?? UserRole.worker.rawValue) {
        case .worker:
            if (work.isMyWork) {
                setGivenLabelColor(work.workerSummary.workerBasedLabelColorStr)
                menuButton.isHidden = false
                dailyIncomeLabel.isHidden = false
            } else {
                setDefaultLabelColor()
                menuButton.isHidden = true
                dailyIncomeLabel.isHidden = true
            }
        case .owner:
            if (work.isMyWork) {
                setDefaultLabelColor()
            } else {
                setGivenLabelColor(work.workerSummary.ownerBasedLabelColorStr)
            }
            menuButton.isHidden = false
            dailyIncomeLabel.isHidden = false
        default:
            setDefaultLabelColor()
        }
        
        titleLabel.text = work.workerSummary.nickname
        sharedChipLabel.isHidden = !work.workplaceSummary.isShared
        
        setTimeInfoUI(startTime: work.startTime, endTime: work.endTime, workMinutes: work.workMinutes)
    }
}
