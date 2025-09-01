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
    private var calendarWorkDataSource: [Date: [CalendarWork]] = [:]
    
    // Initializer Injections
    weak var coordinator: CalendarCoordinator?
    private let viewModel: CalendarViewModel
    
    // Input Relays
    /// 현재 캘린더에 보이는 날짜
    private let visibleDateRelay = PublishRelay<Date>()
    /// 캘린더 개인/공유 모드
    private let calendarModeRelay = BehaviorRelay<CalendarMode>(value: .personal)
    /// 개인 캘린더 근무지/매장 필터
    private let personalFilterWorkplaceRelay = BehaviorRelay<FilterWorkplace?>(value: nil)
    /// 공유 캘린더 근무지/매장 필터
    private let sharedFilterWorkplaceRelay = BehaviorRelay<FilterWorkplace?>(value: nil)
    
    // Others
    /// 현재 캘린더에 보이는 날짜
    private var visibleDate: Date = .now
    /// 선택한 날짜
    private var selectedDate: Date?
    
    // MARK: - UI Components
    private let todayButton = UIBarButtonItem(title: "오늘").then {
        $0.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .normal)
        $0.setTitleTextAttributes([.font: UIFont.headBold(14), .foregroundColor: UIColor.gray900], for: .selected)
    }
    private let calendarView = CalendarView()
    /// `CalendarWorkListModalViewController` 이외 영역의 터치를 제한
    private lazy var calendarViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didCalendarViewTap(_:))).then {
        $0.cancelsTouchesInView = true
        $0.isEnabled = false
    }
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        setActions()
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
    
    // MARK: - setActions
    func setActions() {
        calendarView.addGestureRecognizer(calendarViewTapRecognizer)
    }
    
    // MARK: - setBindings
    func setBindings() {
        // View 바인딩
        todayButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.deselectCell()
                owner.calendarView.getMonthCalendarView.scrollToDate(.now, animateScroll: true)
            }.disposed(by: disposeBag)
        
        calendarView.getCalendarHeaderView.rx.yearMonthButtonTap
            .subscribe(with: self) { owner, _ in
                owner.deselectCell()
                
                guard let title = owner.calendarView.getCalendarHeaderView.getYearMonthButtonTitle,
                      let currYear = Int(title.prefix(4)),
                      let currMonth = Int(title.suffix(2)) else { return }
                owner.coordinator?.showYearMonthPicker(currYear: currYear, currMonth: currMonth)
            }.disposed(by: disposeBag)
        
        calendarView.getCalendarHeaderView.rx.toggleSegmentSelectedIndex
            .subscribe(with: self) { owner, selectedIndex in
                owner.deselectCell()
                owner.calendarModeRelay.accept(CalendarMode.allCases[selectedIndex])
            }.disposed(by: disposeBag)
        
        calendarView.getCalendarHeaderView.rx.filterButtonTap
            .subscribe(with: self) { owner, _ in
                owner.deselectCell()
                
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
        let input = CalendarViewModel.Input(visibleDate: visibleDateRelay.asObservable(),
                                            calendarMode: calendarModeRelay.asObservable(),
                                            personalFilterWorkplace: personalFilterWorkplaceRelay.asObservable(),
                                            sharedFilterWorkplace: sharedFilterWorkplaceRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.calendarWorkList.asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, calendarWorkList in
//                print("==================================================")
//                print("calendarWorkList")
//                dump(calendarWorkList)
//                print("==================================================")
                owner.populateDataSource(calendarWorkList: calendarWorkList)
            }.disposed(by: disposeBag)
    }
}

// MARK: - @objc Methods
@objc private extension CalendarViewController {
    func didCalendarViewTap(_ sender: UITapGestureRecognizer) {
        deselectCell()
    }
}

// MARK: - Internal Calendar Methods
extension CalendarViewController {
    func populateDataSource(calendarWorkList: [CalendarWork]) {
        // TODO: 수신한 데이터 지우지 않는 방향으로 수정
        calendarWorkDataSource.removeAll()
        for work in calendarWorkList {
            guard let workDate = DateFormatter.dataSourceDateFormatter.date(from: work.workDate) else { continue }
            calendarWorkDataSource[workDate, default: []].append(work)
        }
        
        calendarView.getMonthCalendarView.reloadData()
    }
    
    func updateDataSource() {
        visibleDateRelay.accept(visibleDate)
    }
    
    func selectCell(date: Date) {
        calendarView.getMonthCalendarView.scrollToDate(date, animateScroll: true)
        calendarView.getMonthCalendarView.selectDates([date])
    }
    
    func deselectCell() {
        if let selectedDate {
            calendarView.getMonthCalendarView.deselect(dates: [selectedDate])
        }
    }
}

// MARK: - Private Calendar Methods
private extension CalendarViewController {
    func setCalendarView() {
        calendarView.getMonthCalendarView.scrollToDate(visibleDate, animateScroll: false)
    }
    
    func configureCell(cell: JTACDayCell?, cellState: CellState, calendarMode: CalendarMode, workList: [CalendarWork]) {
        guard let cell = cell as? CalendarDayCell else { return }
        
        let dateBelongsToThisMonth = (cellState.dateBelongsTo == .thisMonth)
        let isSelected = cellState.isSelected
        let isToday = Calendar.current.isDateInToday(cellState.date)
        
        cell.update(dateStr: cellState.text,
                    isToday: isToday,
                    daysOfWeek: cellState.day,
                    dateBelongsToThisMonth: dateBelongsToThisMonth,
                    isSelected: isSelected,
                    calendarMode: calendarMode,
                    workList: workList)
    }
    
    func didSelectCell(selectedDate: Date) {
        let selectedDay = Calendar.current.component(.day, from: selectedDate)
        coordinator?.showCalendarWorkList(selectedDay: selectedDay,
                                          calendarWorkList: calendarWorkDataSource[selectedDate] ?? [],
                                          calendarMode: calendarModeRelay.value)
        calendarViewTapRecognizer.isEnabled = true
    }
    
    func didDeselectCell() {
        coordinator?.dismissCalendarWorkList()
        calendarViewTapRecognizer.isEnabled = false
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
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, workList: calendarWorkDataSource[date] ?? [])
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return JTACDayCell()
        }
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, workList: calendarWorkDataSource[date] ?? [])
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        visibleDate = date
        updateDataSource()
        
        let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
        calendarView.getCalendarHeaderView.update(dateStr: dateStr)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = date
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, workList: calendarWorkDataSource[date] ?? [])
        didSelectCell(selectedDate: date)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = nil
        configureCell(cell: cell, cellState: cellState, calendarMode: calendarModeRelay.value, workList: calendarWorkDataSource[date] ?? [])
        didDeselectCell()
    }
}
