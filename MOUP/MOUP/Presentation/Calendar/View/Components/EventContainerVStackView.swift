//
//  EventContainerVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/18/25.
//

import UIKit

import SnapKit

/// 캘린더 날짜 셀 내부 근무 표시 컨테이너 UI
final class EventContainerVStackView: UIStackView {
    
    // MARK: - Properties
    private(set) var isReduced: Bool = false
    private var eventListCount: Int = 0
    
    // MARK: - UI Components
    /// 근무 표시 UI 배열
    private let eventRows = [EventRowVStackView(), EventRowVStackView(), EventRowVStackView(), EventRowVStackView()]
    /// 나머지 근무 개수 표시 UI
    private let restEventCountRow = RestEventCountLabel()
    
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
        self.arrangedSubviews.forEach { $0.isHidden = true }
        
        // 근무가 4개 초과일 때 근무 개수 UI 표시
        let displayLimit = 4
        for (index, event) in eventList.enumerated() {
            if index < displayLimit {
                eventRows[index].update(calendarMode: calendarMode, event: event)
                eventRows[index].isHidden = false
            } else {
                break
            }
        }
        
        eventListCount = eventList.count
        
        // 개인 캘린더 모드) 근무가 2개 초과일 때 급여 라벨 숨김
        if calendarMode == .personal && eventListCount > 2 {
            eventRows.forEach { $0.reduceSize() }
        }
        
        showEventCountRow(displayLimit: displayLimit)
    }
    
    /// `CalendarDayCell`이 공간 부족일 경우 근무 정보 중 일부를 숨김 처리하는 메서드
    func reduceSize() {
        // 근무가 1개 초과일 때 급여 라벨 숨김
        let eventRowCount = eventRows.filter { $0.isHidden == false }.count
        if eventRowCount > 1 {
            eventRows.forEach { $0.reduceSize() }
        }
        eventRows.last?.isHidden = true
        
        // 근무가 3개 초과일 때 근무 개수 UI 표시
        showEventCountRow(displayLimit: 3)
        isReduced = true
    }
    
    /// 숨김 처리된 근무 정보 복구
    func restoreSize() {
        eventRows.forEach { $0.restoreSize() }
        eventRows.last?.isHidden = false
        isReduced = false
    }
}

private extension EventContainerVStackView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        eventRows.forEach { self.addArrangedSubview($0) }
        self.addArrangedSubview(restEventCountRow)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.axis = .vertical
        self.spacing = 4
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        restEventCountRow.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
}

private extension EventContainerVStackView {
    func showEventCountRow(displayLimit: Int) {
        if eventListCount > displayLimit {
            // 마지막 근무 UI 자리에 표시
            eventRows[displayLimit - 1].isHidden = true
            restEventCountRow.text = "+\(eventListCount - displayLimit + 1)"
            restEventCountRow.isHidden = false
        }
    }
}
