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
    private let calendarHeaderView = CalendarHeaderView()
    /// 캘린더
    private let monthCalendarView = JTACMonthView().then {
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .horizontal
        $0.scrollingMode = .stopAtEachCalendarFrame
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    /// 캘린더 요일 표시
    private let dayOfTheWeekHStackView = DaysOfTheWeekHStackView()
    
    // MARK: - Getter
    var getCalendarHeaderView: CalendarHeaderView { calendarHeaderView }
    var getMonthCalendarView: JTACMonthView { monthCalendarView }
    
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
        self.addSubviews(calendarHeaderView,
                         dayOfTheWeekHStackView,
                         monthCalendarView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        calendarHeaderView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        
        dayOfTheWeekHStackView.snp.makeConstraints {
            $0.top.equalTo(calendarHeaderView.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(20)
        }
        
        monthCalendarView.snp.makeConstraints {
            $0.top.equalTo(dayOfTheWeekHStackView.snp.bottom)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Calendar Methods

private extension CalendarView {
    func setCalendarView() {
        monthCalendarView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        
        monthCalendarView.scrollToDate(.now, animateScroll: false)
        
        monthCalendarView.visibleDates { [weak self] visibleDates in
            guard let self, let date = visibleDates.monthDates.first?.date else { return }
            calendarHeaderView.update(date: date)
        }
    }
}
