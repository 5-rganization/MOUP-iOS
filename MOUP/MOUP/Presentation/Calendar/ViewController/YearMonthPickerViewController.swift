//
//  YearMonthPickerViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/26/25.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class YearMonthPickerViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let currYear: Int
    private let currMonth: Int
    
    // MARK: - UI Components
    private lazy var yearMonthPickerView = YearMonthPickerView(currYear: currYear, currMonth: currMonth)
    
    // MARK: - Initializer
    init(currYear: Int, currMonth: Int) {
        self.currYear = currYear
        self.currMonth = currMonth
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = yearMonthPickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension YearMonthPickerViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBinding()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setBinding
    func setBinding() {
        yearMonthPickerView.rx.cancelButtonTap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        yearMonthPickerView.rx.gotoButtonTap
            .subscribe(with: self, onNext: { owner, _ in
//                let (year, month) = owner.yearMonthPickerView.getSelectedYearMonth
                owner.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}
