//
//  EventRowContainerVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/18/25.
//

import UIKit

import SnapKit

/// 캘린더 날짜 셀 내부 근무 표시 컨테이너 UI
final class EventRowContainerVStackView: UIStackView {
    
    // MARK: - UI Components
    /// 첫 번째 열 근무 표시 UI
    private let firstEventRow = EventRowVStackView()
    /// 두 번째 열 근무 표시 UI
    private let secondEventRow = EventRowVStackView()
    /// 세 번째 열 근무 표시 UI
    private let thirdEventRow = EventRowVStackView()
    /// 근무 표시 UI 배열
    private lazy var eventRows = [firstEventRow, secondEventRow, thirdEventRow]
    /// 근무 개수 표시 UI
    private let eventCountRow = EventCountLabel()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Internal Methods
    func update(calendarMode: CalendarMode, eventList: [CalendarEvent]) {
        self.subviews.forEach { $0.isHidden = true }
        
        if !eventList.isEmpty {
            for (index, event) in eventList.enumerated() {
                if index > 2 {
                    if calendarMode == .shared {
                        // 공유 캘린더 모드) 근무가 3개 초과일 때 근무 개수 UI 표시
                        eventCountRow.text = "+\(eventList.count - 3)"
                        eventCountRow.isHidden = false
                    }
                    break
                } else {
                    eventRows[index].update(calendarMode: calendarMode, event: event)
                    eventRows[index].isHidden = false
                }
            }
        }
    }
}

private extension EventRowContainerVStackView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addArrangedSubviews(firstEventRow,
                                 secondEventRow,
                                 thirdEventRow,
                                 eventCountRow)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.axis = .vertical
        self.spacing = 4
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        eventCountRow.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
}
