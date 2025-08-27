//
//  SharedModeEventRowVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

import SnapKit
import Then

/// 캘린더 근무 표시 UI(공유 캘린더 모드)
final class SharedModeEventRowVStackView: BaseEventRowVStackView {
    
    // MARK: - Internal Methods
    override func update(event: CalendarEvent) {
        titleLabel.text = event.workerName
        dailyIncomeLabel.isHidden = true
        
        // TODO: 실제 로그인한 사용자의 ID를 반영해야 함
        // 사용자의 workerId가 789임을 가정
        if event.workerId == 789 {
            setUserLabelColor(event.labelColor)
        } else {
            setOtherLabelColor()
        }
    }
}
