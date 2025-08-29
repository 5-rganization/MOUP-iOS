//
//  SharedModeEventCell.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// 근무 목록 셀(공유 캘린더 모드)
final class SharedModeEventCell: BaseEventCell {
    
    // MARK: - Properties
    static let identifier = String(describing: SharedModeEventCell.self)
    
    // MARK: - Internal Methods
    override func update(event: CalendarEvent) {
        // TODO: 실제 로그인한 사용자의 ID를 반영해야 함
        // 사용자의 workerId가 789임을 가정
        if event.workerId == 789 {
            // TODO: 사장님 역할일 땐 setDefaultLabelColor()
            setGivenLabelColor(event.labelColor)
        } else {
            setDefaultLabelColor()
        }
        
        titleLabel.text = event.workerName
        sharedChipLabel.isHidden = !event.isShared
        
        setTimeInfoUI(startTime: event.startTime, endTime: event.endTime, restTime: event.restTime)
        
        // TODO: 사장님 역할일 때 dailyIncomeLabel 표시
        dailyIncomeLabel.isHidden = true
        // TODO: 알바생 역할일 때 자신의 근무가 아니면 menuButton 숨김
    }
}
