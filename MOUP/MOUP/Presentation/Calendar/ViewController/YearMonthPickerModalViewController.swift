//
//  YearMonthPickerModalViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/26/25.
//

import UIKit

import RxCocoa
import RxSwift

/// `YearMonthPickerModalViewController`의 이벤트를 `YearMonthPickerCoordinator`에 알리는 Delegate
protocol YearMonthPickerModalVCDelegate: AnyObject {
    func dismissGestureReceived()
    func cancelButtonTapped()
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int)
}

/// 연/월 Picker VC
final class YearMonthPickerModalViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    /// `JTACMonthView`가 표시하는 연/월 범위(2차원 `String` 배열)
    private let yearMonthList = [(CalendarRange.startYear...CalendarRange.endYear).map { String($0) }, (1...12).map { String($0) }]
    
    // Initializer Injections
    /// `pickerView`에서 didSelect된 연도
    private var focusedYear: Int
    /// `pickerView`에서 didSelect된 월
    private var focusedMonth: Int
    
    // Property Injections
    weak var delegate: YearMonthPickerModalVCDelegate?
    
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
        setYearMonthPickerView(currYear: focusedYear, currMonth: focusedMonth)
    }
}

private extension YearMonthPickerModalViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setDelegates()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setDelegates
    func setDelegates() {
        self.presentationController?.delegate = self
        
        yearMonthPickerView.getPickerView.dataSource = self
        yearMonthPickerView.getPickerView.delegate = self
    }
    
    // MARK: - setBindings
    func setBindings() {
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

// MARK: - Private Methods
private extension YearMonthPickerModalViewController {
    func setYearMonthPickerView(currYear: Int, currMonth: Int) {
        // 기본 선택 연/월 설정
        let yearRow = currYear - CalendarRange.startYear
        let monthRow = currMonth - 1
        yearMonthPickerView.getPickerView.selectRow(yearRow, inComponent: PickerViewComponents.year, animated: false)
        yearMonthPickerView.getPickerView.selectRow(monthRow, inComponent: PickerViewComponents.month, animated: false)
    }
}

// MARK: - UIPickerViewDataSource
extension YearMonthPickerModalViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return yearMonthList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearMonthList[component].count
    }
}

// MARK: - UIPickerViewDelegate
extension YearMonthPickerModalViewController: UIPickerViewDelegate {
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension YearMonthPickerModalViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.dismissGestureReceived()
    }
}
