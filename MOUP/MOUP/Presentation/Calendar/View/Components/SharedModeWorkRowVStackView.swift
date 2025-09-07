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
    override func update(work: CalendarWork) {
        // TODO: 실제 로그인한 사용자의 ID를 반영해야 함
        // 사용자의 workerId가 789임을 가정
        if work.workerId == 789 {
            // TODO: 사장님 역할일 땐 setDefaultLabelColor()
            setGivenLabelColor(work.labelColor)
        } else {
            setDefaultLabelColor()
        }
        
        titleLabel.text = work.workerName
        dailyIncomeLabel.isHidden = true
    }
}
