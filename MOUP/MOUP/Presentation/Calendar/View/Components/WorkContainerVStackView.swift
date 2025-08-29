//
//  WorkContainerVStackView.swift
//  MOUP
//
//  Created by 서동환 on 8/18/25.
//

import UIKit

import SnapKit

/// 캘린더 날짜 셀 내부 근무 표시 컨테이너 UI
final class WorkContainerVStackView: UIStackView {
    
    // MARK: - Properties
    /// 근무 개수
    private var workListCount: Int = 0
    
    // MARK: - UI Components
    /// 근무 표시 UI 배열(개인 캘린더 모드)
    private let personalModeWorkRows = (0..<4).map { _ in PersonalModeWorkRowVStackView() }
    /// 근무 표시 UI 배열(공유 캘린더 모드)
    private let sharedModeWorkRows = (0..<4).map { _ in SharedModeWorkRowVStackView() }
    /// 미표시된 근무 개수 표시 UI
    private let restWorkCountRow = RestWorkCountRowLabel()
    
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
    ///   - workList: 근무 Entity 배열 `[CalendarWork]`
    ///   - displayCount: 표시할 근무 UI 개수 `Int`
    func updatePersonalModeWorkRows(workList: [CalendarWork], displayCount: Int) {
        self.arrangedSubviews.forEach { $0.isHidden = true }
        
        for (index, work) in workList.enumerated() {
            if index < displayCount {
                personalModeWorkRows[index].update(work: work)
                personalModeWorkRows[index].isHidden = false
            } else {
                break
            }
        }
        
        workListCount = workList.count
        // 근무가 2개 초과일 때 급여 라벨 숨김
        if workListCount > 2 {
            personalModeWorkRows.forEach { $0.reduceSize() }
        }
        
        showRestWorkCountRowIfRemain(displayedCount: displayCount)
    }
    
    /// 공유 캘린더 모드일 때 근무 표시 UI를 업데이트하는 메서드
    /// - Parameters:
    ///   - workList: 근무 Entity 배열 `[CalendarWork]`
    ///   - displayCount: 표시할 근무 UI 개수 `Int`
    func updateSharedModeWorkRows(workList: [CalendarWork], displayCount: Int) {
        self.arrangedSubviews.forEach { $0.isHidden = true }
        
        for (index, work) in workList.enumerated() {
            if index < displayCount {
                sharedModeWorkRows[index].update(work: work)
                sharedModeWorkRows[index].isHidden = false
            } else {
                break
            }
        }
        
        workListCount = workList.count
        
        showRestWorkCountRowIfRemain(displayedCount: displayCount)
    }
    
    /// `CalendarDayCell`이 공간 부족일 경우 UI 중 일부를 숨김 처리하는 메서드
    /// - Parameters:
    ///   - displayCount: 표시할 근무 UI 개수 `Int`
    func reduceHeight(displayCount: Int) {
        if workListCount > 1 {
            personalModeWorkRows.forEach { $0.reduceSize() }
        }
        personalModeWorkRows.dropFirst(displayCount).forEach { $0.isHidden = true }
        
        sharedModeWorkRows.dropFirst(displayCount).forEach { $0.isHidden = true }
        
        showRestWorkCountRowIfRemain(displayedCount: displayCount)
    }
}

private extension WorkContainerVStackView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        personalModeWorkRows.forEach { self.addArrangedSubview($0) }
        sharedModeWorkRows.forEach { self.addArrangedSubview($0) }
        self.addArrangedSubview(restWorkCountRow)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.axis = .vertical
        self.spacing = 4
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        restWorkCountRow.snp.makeConstraints {
            $0.height.equalTo(WorkRowSize.baseComponentHeight)
        }
    }
}

private extension WorkContainerVStackView {
    /// 표시되지 않은 근무 개수를 표시하는 메서드
    /// - Parameters:
    ///   - displayedCount: 표시된 근무 UI 개수 `Int`
    func showRestWorkCountRowIfRemain(displayedCount: Int) {
        if workListCount > displayedCount {
            // 마지막 근무 UI 자리에 표시
            personalModeWorkRows[displayedCount - 1].isHidden = true
            sharedModeWorkRows[displayedCount - 1].isHidden = true
            restWorkCountRow.text = "+\(workListCount - displayedCount + 1)"
            restWorkCountRow.isHidden = false
        }
    }
}
