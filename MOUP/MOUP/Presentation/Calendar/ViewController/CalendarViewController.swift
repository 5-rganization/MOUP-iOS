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

/// 캘린더 탭 VC
final class CalendarViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: CalendarCoordinator?
    
    private let disposeBag = DisposeBag()
    
    private lazy var calendarController = CalendarController(calendarHeaderView: calendarView.getCalendarHeaderView,
                                                             monthCalendarView: calendarView.getMonthCalendarView)
    
    // MARK: - UI Components
    private let calendarView = CalendarView()
    
    // MARK: - Initializer
    init(coordinator: CalendarCoordinator?) {
        self.coordinator = coordinator
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
        self.title = "캘린더"
        
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setDelegates
    func setDelegates() {
        calendarView.getMonthCalendarView.calendarDataSource = calendarController
        calendarView.getMonthCalendarView.calendarDelegate = calendarController
    }
    
    // MARK: - setBindings
    func setBindings() {
        calendarView.getCalendarHeaderView.rx.yearMonthButtonTap
            .subscribe(with: self) { owner, _ in
                guard let config = owner.calendarView.getCalendarHeaderView.getYearMonthButtonConfiguration,
                      let title = config.title,
                      let currYear = Int(title.prefix(4)),
                      let currMonth = Int(title.suffix(2)) else { return }
                
                owner.coordinator?.showYearMonthPicker(currYear: currYear, currMonth: currMonth, delegate: self)
            }.disposed(by: disposeBag)
    }
}

extension CalendarViewController: YearMonthPickerVCDelegate {
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int) {
        let formattedMonth = String(format: "%.2d", focusedMonth)
        guard let date = DateFormatter.dataSourceDateFormatter.date(from: "\(focusedYear).\(formattedMonth).01") else { return }
        calendarController.scrollToDate(date: date)
    }
}
