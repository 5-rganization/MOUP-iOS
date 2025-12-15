//
//  SharedModeWorkRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI(공유 캘린더 모드)
final class SharedModeWorkRowVStackView: BaseWorkRowVStackView {
    
    // MARK: - Internal Methods
    override func update(work: WorkSummary) {
        switch UserRole(rawValue: UserDefaultsManager.shared.userRole ?? UserRole.worker.rawValue) {
        case .worker:
            if work.isMyWork {
                let labelColorStr = work.workerSummary.workerBasedLabelColorStr ?? LabelColor._default.serverStr
                setGivenLabelColor(labelColorStr)
            } else {
                setDefaultLabelColor()
            }
        case .owner:
            if work.isMyWork {
                setDefaultLabelColor()
            } else {
                let labelColorStr = work.workerSummary.ownerBasedLabelColorStr ?? LabelColor._default.serverStr
                setGivenLabelColor(labelColorStr)
            }
        default:
            setDefaultLabelColor()
        }
        
        titleLabel.text = work.workerSummary.nickname
        dailyIncomeLabel.isHidden = true
    }
}
