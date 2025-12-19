//
//  CalendarViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import OSLog

import JTAppleCalendar
import RxCocoa
import RxSwift
import Then

/// 캘린더 탭 VC
final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    /// 캘린더 근무 Dictionary
    private var calendarWorkDataSourceRelay = BehaviorRelay<[Date: Set<WorkSummary>]>(value: [:])
    
    // Initializer Injections
    weak var coordinator: CalendarCoordinator?
    private let viewModel: CalendarViewModel
    
    // Input Relays
    /// 마지막으로 API를 요청한 기준 날짜
    private let lastBaseFetchDateRelay = BehaviorRelay<Date>(value: Date.now.startOfMonth)
    /// 캘린더 개인/공유 모드
    private let calendarModeRelay = BehaviorRelay<CalendarMode>(value: .personal)
    /// 개인 캘린더 근무지/매장 필터
    private let personalFilterWorkplaceRelay = BehaviorRelay<WorkplaceSummary?>(value: nil)
    /// 공유 캘린더 근무지/매장 필터
    private let sharedFilterWorkplaceRelay = BehaviorRelay<WorkplaceSummary?>(value: nil)
    /// `viewWillDisappear` 이벤트
    private let viewWillDisappearRelay = PublishRelay<Void>()
    
    // Others
    /// 현재 캘린더에 보이는 월의 1일
    private var visibleMonthStartDate: Date = .now.startOfMonth {
        didSet {
            visibleMonthStartDate = visibleMonthStartDate.startOfMonth
        }
    }
    /// 선택한 날짜
    private var selectedDate: Date?
    /// 데이터를 로딩할 임계값(며칠을 초과하여 스크롤했을 때 데이터를 로딩할지)
    private let fetchThresholdInDays = 110
    
    // MARK: - UI Components
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedDate {
            selectCell(date: selectedDate)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearRelay.accept(())
    }
    
    // MARK: - Internal Methods
    func updateYearMonth(focusedYear: Int, focusedMonth: Int) {
        let formattedMonth = String(format: "%.2d", focusedMonth)
        guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(focusedYear).\(formattedMonth).01") else { return }
        scrollToDate(date)
    }
    
    func updateFilter(filterWorkplace: WorkplaceSummary?) {
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
        self.navigationController?.navigationBar.isHidden = true
        
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
        calendarView.getNavigationBar.rx.rightBtnTapped
            .subscribe(with: self) { owner, _ in
                owner.deselectCell()
                owner.scrollToDate(.now)
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
                
                let selectedFilterWorkplace: WorkplaceSummary?
                switch owner.calendarModeRelay.value {
                case .personal:
                    selectedFilterWorkplace = owner.personalFilterWorkplaceRelay.value
                case .shared:
                    selectedFilterWorkplace = owner.sharedFilterWorkplaceRelay.value
                }
                owner.coordinator?.showFilter(calendarMode: owner.calendarModeRelay.value, selectedFilterWorkplace: selectedFilterWorkplace)
            }.disposed(by: disposeBag)
        
        // ViewModel 바인딩
        let input = CalendarViewModel.Input(baseFetchDate: lastBaseFetchDateRelay.asObservable().skip(1),
                                            calendarMode: calendarModeRelay.asObservable(),
                                            personalFilterWorkplace: personalFilterWorkplaceRelay.asObservable(),
                                            sharedFilterWorkplace: sharedFilterWorkplaceRelay.asObservable(),
                                            viewWillDisappear: viewWillDisappearRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.calendarWorkDict.asDriver(onErrorJustReturn: [:])
            .drive(with: self) { owner, calendarWorkDict in
                owner.calendarWorkDataSourceRelay.accept(calendarWorkDict)
                owner.calendarView.getMonthCalendarView.reloadData()
            }.disposed(by: disposeBag)
        
        output.errorMessage.asDriver(onErrorJustReturn: (title: "오류 발생", message: "잠시 후 다시 시도해주세요."))
            .drive(with: self) { owner, errorMessage in
                owner.presentNoticeModal(title: errorMessage.title, comment: errorMessage.message)
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
    func updateDataSource() {
        lastBaseFetchDateRelay.accept(visibleMonthStartDate)
    }
    
    func selectCell(date: Date) {
        calendarView.getMonthCalendarView.selectDates([date])
    }
    
    func deselectCell() {
        if let selectedDate { calendarView.getMonthCalendarView.deselect(dates: [selectedDate]) }
    }
}

// MARK: - Private Calendar Methods
private extension CalendarViewController {
    func setCalendarView() {
        scrollToDate(selectedDate ?? visibleMonthStartDate, animateScroll: false) {
            self.updateDataSource()
        }
    }
    
    func updateYearMonthLabel() {
        let dateStr = DateFormatter.presentaionYearMonthDateFormatter.string(from: visibleMonthStartDate)
        calendarView.getCalendarHeaderView.update(dateStr: dateStr)
    }
    
    func scrollToDate(_ date: Date, animateScroll: Bool = true, completionHandler: (() -> Void)? = nil) {
        calendarView.getMonthCalendarView.scrollToDate(date,
                                                       animateScroll: animateScroll,
                                                       completionHandler: completionHandler)
        visibleMonthStartDate = date
        updateYearMonthLabel()
    }
    
    func configureCell(cell: JTACDayCell?, cellState: CellState, calendarMode: CalendarMode, workSet: Set<WorkSummary>) {
        guard let cell = cell as? CalendarDayCell else { return }
        
        let dateBelongsToThisMonth = (cellState.dateBelongsTo == .thisMonth)
        let isToday = Calendar.current.isDateInToday(cellState.date)
        
        let workList = Array(workSet).sorted(by: sortCalendarWorkList)
        
        cell.update(dateStr: cellState.text,
                    isToday: isToday,
                    daysOfWeek: cellState.day,
                    dateBelongsToThisMonth: dateBelongsToThisMonth,
                    calendarMode: calendarMode,
                    workList: workList)
    }
    
    func didSelectCell(selectedDate: Date) {
        let calendarWorkList: Observable<[WorkSummary]> = calendarWorkDataSourceRelay.map { [weak self] dict in
            guard let self else { return [] }
            return Array(dict[selectedDate] ?? []).sorted(by: self.sortCalendarWorkList)
        }
        coordinator?.showCalendarWorkList(selectedDate: selectedDate,
                                          calendarWorkList: calendarWorkList,
                                          calendarMode: calendarModeRelay.value)
        calendarViewTapRecognizer.isEnabled = true
    }
    
    func didDeselectCell() {
        coordinator?.dismissCalendarWorkList()
        calendarViewTapRecognizer.isEnabled = false
    }
    
    func checkPrefetchCondition(date: Date) -> Bool {
        let dayOffset = Calendar.current.dateComponents([.day], from: lastBaseFetchDateRelay.value, to: date).day ?? 111
        return abs(dayOffset) > fetchThresholdInDays
    }
    
    func sortCalendarWorkList(_ lhs: WorkSummary, _ rhs: WorkSummary) -> Bool {
        (lhs.startTime, lhs.endTime ?? Date.distantFuture) < (rhs.startTime, rhs.endTime ?? Date.distantFuture)
    }
}

// MARK: - JTACMonthViewDataSource
extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: CalendarRange.startReferDate,
                                       endDate: CalendarRange.endReferDate,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfRow)
    }
}

// MARK: - JTACMonthViewDelegate
extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(cell: cell,
                      cellState: cellState,
                      calendarMode: calendarModeRelay.value,
                      workSet: calendarWorkDataSourceRelay.value[date] ?? [])
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return JTACDayCell()
        }
        configureCell(cell: cell,
                      cellState: cellState,
                      calendarMode: calendarModeRelay.value,
                      workSet: calendarWorkDataSourceRelay.value[date] ?? [])
        return cell
    }
    
    // 사용자의 터치에 의해서만 호출됨, programmatic한 스크롤의 경우 호출 X
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        visibleMonthStartDate = date
        
        // 셀 선택 해제
        deselectCell()
        
        // 연/월 라벨 변경
        updateYearMonthLabel()
        
        // 근무 데이터 로딩
        if checkPrefetchCondition(date: date) {
            logger.info("[\(#function)] 캘린더 근무 데이터 Prefetch")
            updateDataSource()
        }
    }
    
    // 사용자의 터치, programmatic한 스크롤 모두 호출
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        
        // 근무 데이터 로딩 (willScrollToDateSegmentWith에서 로딩한 경우 fetchThresholdInDays에 의해 실행 X)
        if checkPrefetchCondition(date: date) {
            logger.info("[\(#function)] 캘린더 근무 데이터 Prefetch")
            updateDataSource()
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = date
        configureCell(cell: cell,
                      cellState: cellState,
                      calendarMode: calendarModeRelay.value,
                      workSet: calendarWorkDataSourceRelay.value[date] ?? [])
        didSelectCell(selectedDate: date)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        selectedDate = nil
        configureCell(cell: cell,
                      cellState: cellState,
                      calendarMode: calendarModeRelay.value,
                      workSet: calendarWorkDataSourceRelay.value[date] ?? [])
        didDeselectCell()
    }
}
