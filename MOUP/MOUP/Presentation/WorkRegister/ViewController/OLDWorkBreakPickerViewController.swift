//
//  OLDWorkBreakPickerViewController.swift
//  MOUP
//
//  Created by 양원식 on 9/16/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OLDWorkBreakPickerViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OLDWorkBreakPickerViewModel
    private let contentView = OLDWorkDatePickerView()
    private let disposeBag = DisposeBag()
    
    // Picker data (30분 단위, 최대 5시간 예시)
    private var breakMinutes: [Int] = Array(stride(from: 0, through: 300, by: 30))
    
    // local state
    private var curIndex = 0
    
    // MARK: - Init
    init(viewModel: OLDWorkBreakPickerViewModel) {
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
        viewModel.resetToConfirmedIndex()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet()
        setDelegates()
        bind()
    }
    
    private func setupSheet() {
        view.backgroundColor = .white
        if let sheet = sheetPresentationController, #available(iOS 16.0, *) {
            sheet.detents = [.custom { _ in 260 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
        }
    }
    
    private func setDelegates() {
        contentView.getPickerView.dataSource = self
        contentView.getPickerView.delegate = self
    }
    
    private func bind() {
        // Buttons
        contentView.getConfirmButton.rx.tap
            .bind(to: viewModel.didTapConfirm)
            .disposed(by: disposeBag)
        
        contentView.getCancelButton.rx.tap
            .bind(to: viewModel.didTapCancel)
            .disposed(by: disposeBag)
        
        // Preselect
        viewModel.currentIndex
            .drive(onNext: { [weak self] idx in
                guard let self else { return }
                self.curIndex = idx
                self.contentView.getPickerView.selectRow(idx, inComponent: 0, animated: false)
            })
            .disposed(by: disposeBag)
        
        // Close on confirm/dismiss
        viewModel.confirmSelectedBreak
            .subscribe(onNext: { [weak self] _ in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)
        
        viewModel.dismiss
            .subscribe(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIPickerView
extension OLDWorkBreakPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        breakMinutes.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 44 }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        let minutes = breakMinutes[row]
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 && mins > 0 {
            return "\(hours)시간 \(mins)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else if mins > 0 {
            return "\(mins)분"
        } else {
            return "없음"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        curIndex = row
        viewModel.selectedIndex.onNext(row)
    }
}
