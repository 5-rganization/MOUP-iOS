//
//  CalendarController.swift
//  MOUP
//
//  Created by 서동환 on 7/21/25.
//

import JTAppleCalendar

/// 캘린더의 동작을 제어하는 컨트롤러
final class CalendarController {
    // MARK: - Properties
    /// 캘린더 헤더
    private let calendarHeaderView: CalendarHeaderView
    /// 캘린더
    private let monthCalendarView: JTACMonthView
    
    // MARK: - Initializer
    init(calendarHeaderView: CalendarHeaderView, monthCalendarView: JTACMonthView) {
        self.calendarHeaderView = calendarHeaderView
        self.monthCalendarView = monthCalendarView
        
        setCalendarView()
    }
}

// MARK: - Internal Calendar Methods
extension CalendarController {
    func scrollToDate(date: Date) {
        monthCalendarView.scrollToDate(date, animateScroll: true)
    }
}

// MARK: - Private Calendar Methods
private extension CalendarController {
    func setCalendarView() {
        monthCalendarView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        
        monthCalendarView.scrollToDate(.now, animateScroll: false)
        
        monthCalendarView.visibleDates { [weak self] visibleDates in
            guard let self, let date = visibleDates.monthDates.first?.date else { return }
            let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
            calendarHeaderView.update(dateStr: dateStr)
        }
    }
    
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
        let startDate = DateFormatter.dataSourceDateFormatter.date(from: "\(CalendarRange.startYear).01.01")
        let endDate = DateFormatter.dataSourceDateFormatter.date(from: "\(CalendarRange.endYear).12.31")
        
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
        let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
        calendarHeaderView.update(dateStr: dateStr)
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
