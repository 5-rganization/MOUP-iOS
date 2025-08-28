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
    /// 근무 개수
    private var eventListCount: Int = 0
    
    // MARK: - UI Components
    /// 근무 표시 UI 배열(개인 캘린더 모드)
    private let personalModeEventRows = (0..<4).map { _ in PersonalModeEventRowVStackView() }
    /// 근무 표시 UI 배열(공유 캘린더 모드)
    private let sharedModeEventRows = (0..<4).map { _ in SharedModeEventRowVStackView() }
    /// 미표시된 근무 개수 표시 UI
    private let restEventCountRow = RestEventCountRowLabel()
    
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
    /// 개인 캘린더 모드일 때 근무 표시 UI를 업데이트하는 메서드
    /// - Parameters:
    ///   - eventList: 근무 Entity 배열 `[CalendarEvent]`
    ///   - displayCount: 표시할 근무 UI 개수 `Int`
    func updatePersonalModeEventRows(eventList: [CalendarEvent], displayCount: Int) {
        self.arrangedSubviews.forEach { $0.isHidden = true }
        
        for (index, event) in eventList.enumerated() {
            if index < displayCount {
                personalModeEventRows[index].update(event: event)
                personalModeEventRows[index].isHidden = false
            } else {
                break
            }
        }
        
        eventListCount = eventList.count
        // 근무가 2개 초과일 때 급여 라벨 숨김
        if eventListCount > 2 {
            personalModeEventRows.forEach { $0.reduceSize() }
        }
        
        showRestEventCountRowIfRemain(displayedCount: displayCount)
    }
    
    /// 공유 캘린더 모드일 때 근무 표시 UI를 업데이트하는 메서드
    /// - Parameters:
    ///   - eventList: 근무 Entity 배열 `[CalendarEvent]`
    ///   - displayCount: 표시할 근무 UI 개수 `Int`
    func updateSharedModeEventRows(eventList: [CalendarEvent], displayCount: Int) {
        self.arrangedSubviews.forEach { $0.isHidden = true }
        
        for (index, event) in eventList.enumerated() {
            if index < displayCount {
                sharedModeEventRows[index].update(event: event)
                sharedModeEventRows[index].isHidden = false
            } else {
                break
            }
        }
        
        eventListCount = eventList.count
        
        showRestEventCountRowIfRemain(displayedCount: displayCount)
    }
    
    /// `CalendarDayCell`이 공간 부족일 경우 UI 중 일부를 숨김 처리하는 메서드
    /// - Parameters:
    ///   - displayCount: 표시할 근무 UI 개수 `Int`
    func reduceHeight(displayCount: Int) {
        if eventListCount > 1 {
            personalModeEventRows.forEach { $0.reduceSize() }
        }
        personalModeEventRows.dropFirst(displayCount).forEach { $0.isHidden = true }

        sharedModeEventRows.dropFirst(displayCount).forEach { $0.isHidden = true }
        
        showRestEventCountRowIfRemain(displayedCount: displayCount)
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
        personalModeEventRows.forEach { self.addArrangedSubview($0) }
        sharedModeEventRows.forEach { self.addArrangedSubview($0) }
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
            $0.height.equalTo(EventRowSize.baseComponentHeight)
        }
    }
}

private extension EventContainerVStackView {
    /// 표시되지 않은 근무 개수를 표시하는 메서드
    /// - Parameters:
    ///   - displayedCount: 표시된 근무 UI 개수 `Int`
    func showRestEventCountRowIfRemain(displayedCount: Int) {
        if eventListCount > displayedCount {
            // 마지막 근무 UI 자리에 표시
            personalModeEventRows[displayedCount - 1].isHidden = true
            sharedModeEventRows[displayedCount - 1].isHidden = true
            restEventCountRow.text = "+\(eventListCount - displayedCount + 1)"
            restEventCountRow.isHidden = false
        }
    }
}
