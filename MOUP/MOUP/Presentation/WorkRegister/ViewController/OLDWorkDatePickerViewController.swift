//
//  OLDWorkDatePickerViewController.swift
//  MOUP
//
//  Created by 양원식 on 8/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OLDWorkDatePickerViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: OLDWorkDatePickerViewModel
    private let contentView = OLDWorkDatePickerView()
    private let disposeBag = DisposeBag()

    // Picker data
    private var years: [Int] = []
    private let months = Array(1...12)
    private var days: [Int] = []
    private let calendar = Calendar(identifier: .gregorian)

    // local state for clamping
    private var curYear = 0
    private var curMonth = 1
    private var curDay = 1

    // MARK: - Init
    init(viewModel: OLDWorkDatePickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    @available(*, unavailable, message: "Storyboard is not supported.")
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented.") }

    // MARK: - Lifecycle
    override func loadView() { self.view = contentView }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetToConfirmedDate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet()
        setupYears()
        setDelegates()
        bind()
    }

    private func setupSheet() {
        view.backgroundColor = .white
        if let sheet = sheetPresentationController, #available(iOS 16.0, *) {
            sheet.detents = [.custom { _ in 320 }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
    }

    private func setupYears() {
        let nowY = calendar.component(.year, from: Date())
        years = Array((nowY - 50)...(nowY + 50))
        rebuildDays(year: nowY, month: 1) // 초기 days
    }

    private func setDelegates() {
        contentView.getPickerView.dataSource = self
        contentView.getPickerView.delegate = self
    }

    private func rebuildDays(year: Int, month: Int) {
        if let date = calendar.date(from: DateComponents(year: year, month: month)),
           let range = calendar.range(of: .day, in: .month, for: date) {
            days = Array(range)
        } else {
            days = Array(1..<32)
        }
    }


    private func clampAndApplyDay(on pickerView: UIPickerView) {
        let clamped = min(curDay, days.count)
        if clamped != curDay {
            curDay = clamped
            viewModel.selectedDay.onNext(clamped)
        }
        pickerView.reloadComponent(2)
        pickerView.selectRow(clamped - 1, inComponent: 2, animated: true)
    }

    private func bind() {
        // Buttons
        contentView.getConfirmButton.rx.tap
            .bind(to: viewModel.didTapConfirm)
            .disposed(by: disposeBag)

        contentView.getCancelButton.rx.tap
            .bind(to: viewModel.didTapCancel)
            .disposed(by: disposeBag)

        // Keep local states & preselect rows
        viewModel.currentYear
            .drive(onNext: { [weak self] y in
                guard let self else { return }
                self.curYear = y
                if let idx = self.years.firstIndex(of: y) {
                    self.contentView.getPickerView.selectRow(idx, inComponent: 0, animated: false)
                }
            })
            .disposed(by: disposeBag)

        viewModel.currentMonth
            .drive(onNext: { [weak self] m in
                guard let self else { return }
                self.curMonth = m
                self.contentView.getPickerView.selectRow(m - 1, inComponent: 1, animated: false)
                self.rebuildDays(year: self.curYear, month: m)
            })
            .disposed(by: disposeBag)

        viewModel.currentDay
            .drive(onNext: { [weak self] d in
                guard let self else { return }
                self.curDay = d
                let row = max(0, min(self.days.count - 1, d - 1))
                self.contentView.getPickerView.selectRow(row, inComponent: 2, animated: false)
            })
            .disposed(by: disposeBag)

        // Close on confirm/dismiss (값은 상위 VC에서 구독)
        viewModel.confirmSelectedDate
            .subscribe(onNext: { [weak self] _ in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)

        viewModel.dismiss
            .subscribe(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIPickerView
extension OLDWorkDatePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int { 3 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return years.count
        case 1: return months.count
        case 2: return days.count
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 44 }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 110
        case 1: return 80
        case 2: return 80
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(years[row])"
        case 1: return "\(months[row])"
        case 2: return "\(days[row])"
        default: return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            curYear = years[row]
            viewModel.selectedYear.onNext(curYear)
            rebuildDays(year: curYear, month: curMonth)
            clampAndApplyDay(on: pickerView)

        case 1:
            curMonth = months[row]
            viewModel.selectedMonth.onNext(curMonth)
            rebuildDays(year: curYear, month: curMonth)
            clampAndApplyDay(on: pickerView)

        case 2:
            curDay = days[row]
            viewModel.selectedDay.onNext(curDay)

        default: break
        }
    }
}
