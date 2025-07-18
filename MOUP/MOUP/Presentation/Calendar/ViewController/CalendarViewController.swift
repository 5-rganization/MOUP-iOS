//
//  CalendarViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: CalendarCoordinator?
    
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
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
        
        self.navigationController?.navigationBar.isHidden = true
    }
}
