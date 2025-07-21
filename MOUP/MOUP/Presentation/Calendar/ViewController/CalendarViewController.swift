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
    
    private lazy var calendarController = CalendarController(calendarHeaderView: calendarView.calendarHeaderView,
                                                             monthCalendarView: calendarView.monthCalendarView)
    
    // MARK: - UI Components
    
    private let calendarView = CalendarView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = calendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: - UI Methods

private extension CalendarViewController {
    func configure() {
        setStyles()
        setDelegates()
    }
    
    func setStyles() {
        self.title = "캘린더"
        
        self.view.backgroundColor = .primaryBackground
    }
    
    func setDelegates() {
        calendarView.monthCalendarView.calendarDataSource = calendarController
        calendarView.monthCalendarView.calendarDelegate = calendarController
    }
}
