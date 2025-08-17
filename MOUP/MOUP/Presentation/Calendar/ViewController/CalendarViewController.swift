//
//  CalendarViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

import JTAppleCalendar
import RxCocoa
import RxSwift
import Then

/// 캘린더 탭 VC
final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    /// 캘린더 근무 Dictionary
    private var calendarEventDataSource: [Date: [CalendarEvent]] = [:]
    
    // Initializer Injections
    weak var coordinator: CalendarCoordinator?
    private let viewModel: CalendarViewModel
    
    // Input Relays
    /// 현재 캘린더 연/월
    private let visibleYearMonthRelay = PublishRelay<(year: Int, month: Int)>()
    /// 캘린더 개인/공유 모드
    private let calendarModeRelay = BehaviorRelay<CalendarMode>(value: .personal)
    /// 개인 캘린더 근무지/매장 필터
    private let personalFilterWorkplaceRelay = BehaviorRelay<FilterWorkplace?>(value: nil)
    /// 공유 캘린더 근무지/매장 필터
    private let sharedFilterWorkplaceRelay = BehaviorRelay<FilterWorkplace?>(value: nil)
    
    // MARK: - UI Components
    private let todayButton = UIBarButtonItem(title: "오늘").then {
        $0.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .normal)
        $0.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .selected)
    }
    private let calendarView = CalendarView()
    
    // MARK: - Initializer
    init(coordinator: CalendarCoordinator, viewModel: CalendarViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = calendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setCalendarView()
    }
    
    // MARK: - Internal Methods
    func updateYearMonth(focusedYear: Int, focusedMonth: Int) {
        let formattedMonth = String(format: "%.2d", focusedMonth)
        guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(focusedYear).\(formattedMonth).01") else { return }
        calendarView.getMonthCalendarView.scrollToDate(date, animateScroll: true)
    }
    
    func updateFilter(filterWorkplace: FilterWorkplace?) {
        switch calendarModeRelay.value {
        case .personal:
            personalFilterWorkplaceRelay.accept(filterWorkplace)
        case .shared:
            sharedFilterWorkplaceRelay.accept(filterWorkplace)
        }
    }
}

private extension CalendarViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setDelegates()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.setNavigationBar(title: "캘린더")
        self.navigationItem.rightBarButtonItem = todayButton
        
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setDelegates
    func setDelegates() {
        calendarView.getMonthCalendarView.calendarDataSource = self
        calendarView.getMonthCalendarView.calendarDelegate = self
    }
    
    // MARK: - setBindings
    func setBindings() {
        // View 바인딩
        todayButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.calendarView.getMonthCalendarView.deselectAllDates()
                owner.calendarView.getMonthCalendarView.scrollToDate(.now, animateScroll: true)
            }.disposed(by: disposeBag)
        
        calendarView.getCalendarHeaderView.rx.yearMonthButtonTap
            .subscribe(with: self) { owner, _ in
                guard let title = owner.calendarView.getCalendarHeaderView.getYearMonthButtonTitle,
                      let currYear = Int(title.prefix(4)),
                      let currMonth = Int(title.suffix(2)) else { return }
                owner.coordinator?.showYearMonthPicker(currYear: currYear, currMonth: currMonth)
            }.disposed(by: disposeBag)
        
        calendarView.getCalendarHeaderView.rx.toggleSegmentSelectedIndex
            .subscribe(with: self) { owner, selectedIndex in
                owner.calendarModeRelay.accept(CalendarMode.allCases[selectedIndex])
            }.disposed(by: disposeBag)
        
        calendarView.getCalendarHeaderView.rx.filterButtonTap
            .subscribe(with: self) { owner, _ in
                let selectedFilterWorkplace: FilterWorkplace?
                switch owner.calendarModeRelay.value {
                case .personal:
                    selectedFilterWorkplace = owner.personalFilterWorkplaceRelay.value
                case .shared:
                    selectedFilterWorkplace = owner.sharedFilterWorkplaceRelay.value
                }
                owner.coordinator?.showFilter(calendarMode: owner.calendarModeRelay.value, selectedFilterWorkplace: selectedFilterWorkplace)
            }.disposed(by: disposeBag)
        
        // ViewModel 바인딩
        let input = CalendarViewModel.Input(visibleYearMonth: visibleYearMonthRelay.asObservable(),
                                            calendarMode: calendarModeRelay.asObservable(),
                                            personalFilterWorkplace: personalFilterWorkplaceRelay.asObservable(),
                                            sharedFilterWorkplace: sharedFilterWorkplaceRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.calendarEventList.asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, calendarEventList in
                print("calendarEventList")
                dump(calendarEventList)
                owner.populateDataSource(calendarEventList: calendarEventList)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Internal Calendar Methods
extension CalendarViewController {
    func populateDataSource(calendarEventList: [CalendarEvent]) {
        for event in calendarEventList {
            guard let eventDate = DateFormatter.dataSourceDateFormatter.date(from: event.workDate) else { continue }
            calendarEventDataSource[eventDate, default: []].append(event)
        }
        calendarView.getMonthCalendarView.reloadData()
    }
}

// MARK: - Private Calendar Methods
private extension CalendarViewController {
    func setCalendarView() {
        calendarView.getMonthCalendarView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        
        calendarView.getMonthCalendarView.scrollToDate(.now, animateScroll: false)
        
        calendarView.getMonthCalendarView.visibleDates { [weak self] visibleDates in
            guard let self, let date = visibleDates.monthDates.first?.date else { return }
            let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
            calendarView.getCalendarHeaderView.update(dateStr: dateStr)
        }
    }
    
    func configureCell(cell: JTACDayCell?, cellState: CellState, calendarMode: CalendarMode, eventList: [CalendarEvent]) {
        guard let cell = cell as? CalendarDayCell else { return }
        
        let dateBelongsToThisMonth = (cellState.dateBelongsTo == .thisMonth)
        let isSelected = cellState.isSelected
        let isToday = Calendar.current.isDateInToday(cellState.date)
        
        cell.update(dateStr: cellState.text,
                    daysOfWeek: cellState.day,
                    dateBelongsToThisMonth: dateBelongsToThisMonth,
                    isSelected: isSelected,
                    isToday: isToday)
    }
}

// MARK: - JTACMonthViewDataSource
extension CalendarViewController: JTACMonthViewDataSource {
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
extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return JTACDayCell()
        }
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, eventList: calendarEventDataSource[date] ?? [])
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
        calendarView.getCalendarHeaderView.update(dateStr: dateStr)
        visibleYearMonthRelay.accept((year: Calendar.current.component(.year, from: date),
                                      month: Calendar.current.component(.month, from: date)))
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, eventList: calendarEventDataSource[date] ?? [])
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, eventList: calendarEventDataSource[date] ?? [])
    }
}
