//
//  WorkTimePickerViewController.swift
//  MOUP
//
//  Created by 양원식 on 8/13/25.
//

import UIKit
import RxSwift
import RxCocoa

final class WorkTimePickerViewController: UIViewController {

    private let contentView = WorkTimePickerView()
    private let viewModel: WorkTimePickerViewModel
    private let disposeBag = DisposeBag()

    // Picker data
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
    private var ampmStrings: [String] { [formatter.amSymbol, formatter.pmSymbol] } // ["오전","오후"]
    private let hours: [Int] = Array(1...12)
    private let minutes: [Int] = Array(0...59)

    // MARK: - Init
    init(viewModel: WorkTimePickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in 300 }] // 높이 적당히
            sheet.prefersGrabberVisible = false
        }
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented.") }

    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupPicker()
    }

    private func setupPicker() {
        let picker = contentView.getPickerView
        picker.dataSource = self
        picker.delegate = self

        // 초기 선택 동기화
        viewModel.currentAMPM.drive(onNext: { [weak picker] ampm in
            picker?.selectRow(ampm, inComponent: 0, animated: false)
        }).disposed(by: disposeBag)

        viewModel.currentHour.drive(onNext: { [weak self] hour in
            guard let self else { return }
            if let idx = self.hours.firstIndex(of: hour) {
                self.contentView.getPickerView.selectRow(idx, inComponent: 1, animated: false)
            }
        }).disposed(by: disposeBag)

        viewModel.currentMinute.drive(onNext: { [weak self] minute in
            guard let self else { return }
            self.contentView.getPickerView.selectRow(minute, inComponent: 2, animated: false)
        }).disposed(by: disposeBag)
    }

    private func bind() {
        // Buttons -> Inputs
        contentView.getCancelButton.rx.tap
            .do(onNext: { [weak self] in self?.viewModel.resetToConfirmedTime() })
            .bind(to: viewModel.didTapCancel)
            .disposed(by: disposeBag)

        contentView.getConfirmButton.rx.tap
            .bind(to: viewModel.didTapConfirm)
            .disposed(by: disposeBag)

        // Outputs
        viewModel.dismiss
            .bind(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)
    }
}

extension WorkTimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return ampmStrings.count     // AM/PM
        case 1: return hours.count          // 1..12
        case 2: return minutes.count        // 0..59
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 80
        case 1: return 80
        case 2: return 100
        default: return 80
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return ampmStrings[row]
        case 1: return "\(hours[row])시"
        case 2:
            let m = minutes[row]
            return String(format: "%02d분", m)
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            viewModel.selectedAMPM.onNext(row) // 0 or 1
        case 1:
            viewModel.selectedHour.onNext(hours[row]) // 1..12
        case 2:
            viewModel.selectedMinute.onNext(minutes[row]) // 0..59
        default:
            break
        }
    }
}
