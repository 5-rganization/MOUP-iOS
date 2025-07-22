//
//  CalendarView.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

import JTAppleCalendar
import RxCocoa
import RxSwift
import SnapKit
import Then

/// 캘린더 UI
final class CalendarView: UIView {
    // MARK: - UI Components
    /// 캘린더 상단 헤더
    private let _calendarHeaderView = CalendarHeaderView()
    /// 캘린더
    private let _monthCalendarView = JTACMonthView().then {
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .horizontal
        $0.scrollingMode = .stopAtEachCalendarFrame
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    /// 캘린더 요일 표시
    private let _dayOfTheWeekHStackView = DaysOfTheWeekHStackView()
    
    // MARK: - Getter
    var calendarHeaderView: CalendarHeaderView { _calendarHeaderView }
    var monthCalendarView: JTACMonthView { _monthCalendarView }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setCalendarView()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension CalendarView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addSubviews(_calendarHeaderView,
                         _dayOfTheWeekHStackView,
                         _monthCalendarView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        _calendarHeaderView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        
        _dayOfTheWeekHStackView.snp.makeConstraints {
            $0.top.equalTo(_calendarHeaderView.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(20)
        }
        
        _monthCalendarView.snp.makeConstraints {
            $0.top.equalTo(_dayOfTheWeekHStackView.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Calendar Methods

private extension CalendarView {
    func setCalendarView() {
        _monthCalendarView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        
        _monthCalendarView.scrollToDate(.now, animateScroll: false)
        
        _monthCalendarView.visibleDates { [weak self] visibleDates in
            guard let self, let date = visibleDates.monthDates.first?.date else { return }
            _calendarHeaderView.update(date: date)
        }
    }
}
