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

/// `YearMonthPickerViewController`의 이벤트 및 데이터를 `CalendarViewController`로 넘겨주는 Delegate
protocol YearMonthPickerVCDelegate: AnyObject {
    func cancelButtonTapped()
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int)
}

final class YearMonthPickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: YearMonthPickerVCDelegate?
    
    private let disposeBag = DisposeBag()
    
    /// `JTACMonthView`가 표시하는 연/월 범위(2차원 `String` 배열)
    private let yearMonthList = [(CalendarRange.startYear...CalendarRange.endYear).map { String($0) }, (1...12).map { String($0) }]
    
    /// `pickerView`에서 didSelect된 연도
    private var focusedYear: Int
    /// `pickerView`에서 didSelect된 월
    private var focusedMonth: Int
    
    // MARK: - UI Components
    private let yearMonthPickerView = YearMonthPickerView()
    
    // MARK: - Initializer
    init(currYear: Int, currMonth: Int) {
        self.focusedYear = currYear
        self.focusedMonth = currMonth
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
        setDefaultSelect(currYear: focusedYear, currMonth: focusedMonth)
    }
}

private extension YearMonthPickerViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setDelegates()
        setBinding()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setDelegates
    func setDelegates() {
        yearMonthPickerView.getPickerView.dataSource = self
        yearMonthPickerView.getPickerView.delegate = self
    }
    
    // MARK: - setBinding
    func setBinding() {
        yearMonthPickerView.rx.cancelButtonTap
            .subscribe(with: self) { owner, _ in
                owner.delegate?.cancelButtonTapped()
            }.disposed(by: disposeBag)
        
        yearMonthPickerView.rx.gotoButtonTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.delegate?.gotoButtonTapped(focusedYear: owner.focusedYear, focusedMonth: owner.focusedMonth)
            }).disposed(by: disposeBag)
    }
}

// MARK: - UIPickerViewDataSource
extension YearMonthPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return yearMonthList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearMonthList[component].count
    }
}

// MARK: - UIPickerViewDelegate
extension YearMonthPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.text = yearMonthList[component][row]
        label.font = .headBold(20)
        label.textColor = .gray900
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case PickerViewComponents.year:
            focusedYear = row + CalendarRange.startYear
        case PickerViewComponents.month:
            focusedMonth = row + 1
        default:
            break
        }
    }
}

// MARK: - Private Methods
private extension YearMonthPickerViewController {
    func setDefaultSelect(currYear: Int, currMonth: Int) {
        let yearRow = currYear - CalendarRange.startYear
        let monthRow = currMonth - 1
        yearMonthPickerView.getPickerView.selectRow(yearRow, inComponent: PickerViewComponents.year, animated: false)
        yearMonthPickerView.getPickerView.selectRow(monthRow, inComponent: PickerViewComponents.month, animated: false)
    }
}
