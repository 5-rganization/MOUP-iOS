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

final class CalendarView: UIView {
    
    // MARK: - UI Components
    
    /// 캘린더 상단 헤더
    private let calendarHeaderView = CalendarHeaderView()
    /// 캘린더
    private let monthCalendarView = JTACMonthView().then {
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .horizontal
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    /// 캘린더 요일 표시
    private let dayOfTheWeekHStackView = DayOfTheWeekHStackView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

// MARK: - UI Methods

private extension CalendarView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(calendarHeaderView,
                         dayOfTheWeekHStackView,
                         monthCalendarView)
    }
    
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
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
