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
        guard let borderColor = LabelColorString(rawValue: event.labelColor) else {
            assertionFailure("LabelColorString 변환 실패 - labelColor 값이 올바르지 않습니다.")
            return
        }
        labelColorBorderView.update(borderColor: borderColor)
    }
}
