//
//  ManageAttendanceViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift

class ManageAttendanceViewController: UIViewController {
    // MARK: - Properties
    private let manageAttendanceView = ManageAttendanceView()
    private let viewModel: ManageAttendanceViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - loadView
    override func loadView() {
        view = manageAttendanceView
    }
    
    // MARK: - Initializer
    init(viewModel: ManageAttendanceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension ManageAttendanceViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setBindings
    func setBindings() {
        
    }
}
