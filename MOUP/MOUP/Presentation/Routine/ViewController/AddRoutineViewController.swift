//
//  AddRoutineViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import UIKit

final class AddRoutineViewController: UIViewController {
    
    // MARK: - Properties
    
    private let addRoutineView = AddRoutineView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = addRoutineView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension AddRoutineViewController {
    // MARK: - configure
    func configure() {
        
    }
}
