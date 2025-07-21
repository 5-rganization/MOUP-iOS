//
//  CalendarController.swift
//  MOUP
//
//  Created by 서동환 on 7/21/25.
//

import Foundation
import JTAppleCalendar

/// `JTACMonthView`의 동작을 제어하는 클래스
final class CalendarController {
    
    // MARK: - Properties
    
    /// `JTACMonthView`의 날짜 생성 범위를 설정하는 `enum`
    private enum CalendarRange: Int {
        /// 캘린더 생성 시작 연도
        case startYear = 2001
        /// 캘린더 생성 끝 연도
        case endYear = 2100
        
        var referenceDate: Date {
            switch self {
            case .startYear:
                guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(self.rawValue).01.01") else {
                    return Date(timeIntervalSinceReferenceDate: 0.0)
                }
                return date
            case .endYear:
                guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(self.rawValue).12.31") else {
                    return .now
                }
                return date
            }
        }
    }
    /// 캘린더 헤더
    private let calendarHeaderView: CalendarHeaderView
    /// 캘린더
    private let monthCalendarView: JTACMonthView
    
    // MARK: - Initializer
    
    init(calendarHeaderView: CalendarHeaderView, monthCalendarView: JTACMonthView) {
        self.calendarHeaderView = calendarHeaderView
        self.monthCalendarView = monthCalendarView
    }
}

// MARK: - Calendar Methods

private extension CalendarController {
    func configureCell(cell: JTACDayCell?, cellState: CellState) {
        guard let cell = cell as? CalendarDayCell else { return }
        handleCellColor(cell: cell, cellState: cellState)
        handleCellSelection(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    
    func handleCellColor(cell: CalendarDayCell, cellState: CellState) {
        let dateBelongsToThisMonth = (cellState.dateBelongsTo == .thisMonth)
        cell.dayLabel.isHidden = !dateBelongsToThisMonth
        cell.isUserInteractionEnabled = dateBelongsToThisMonth
    }
    
    func handleCellSelection(cell: CalendarDayCell, cellState: CellState) {
        cell.selectedView.isHidden = !cellState.isSelected
    }
    
    func handleCellEvents(cell: CalendarDayCell, cellState: CellState) {
        var calendar = Calendar.current
        calendar.timeZone = .autoupdatingCurrent
        
        cell.update(dateStr: cellState.text,
                    daysOfWeek: cellState.day,
                    isToday: calendar.isDateInToday(cellState.date))
    }
}

// MARK: - JTACMonthViewDataSource

extension CalendarController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let startDate = DateFormatter.dataSourceDateFormatter.date(from: "\(CalendarRange.startYear.rawValue).01.01")
        let endDate = DateFormatter.dataSourceDateFormatter.date(from: "\(CalendarRange.endYear.rawValue).12.31")
        
        return ConfigurationParameters(startDate: startDate ?? .distantPast,
                                       endDate: endDate ?? .distantFuture,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfRow)
    }
}

// MARK: - JTACMonthViewDelegate

extension CalendarController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return JTACDayCell()
        }
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        calendarHeaderView.update(date: date)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState)
    }
}
