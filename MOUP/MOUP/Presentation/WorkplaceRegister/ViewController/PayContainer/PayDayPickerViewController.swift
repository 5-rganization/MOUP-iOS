//
//  PayDayPickerViewController.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//
import UIKit
import RxSwift
import RxCocoa

final class PayDayPickerViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: PayDayPickerViewModel
    private let payDayPickerView = PayDayPickerView()
    private let disposeBag = DisposeBag()

    // MARK: - Initializer
    init(viewModel: PayDayPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    @available(*, unavailable, message: "Storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Lifecycle
    override func loadView() {
        self.view = payDayPickerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetToConfirmedDay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        payDayPickerView.getPickerView.delegate = self
        payDayPickerView.getPickerView.dataSource = self
        configure()
    }
}

// MARK: - UI Methods
private extension PayDayPickerViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }

    func setHierarchy() { }

    func setStyles() {
        view.backgroundColor = .white
        
        if let sheet = self.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in return 300 }]
                sheet.prefersGrabberVisible = false
                sheet.preferredCornerRadius = 16
            }
        }
    }

    func setConstraints() { }

    func setActions() {
        payDayPickerView.getConfirmButton
            .rx.tap
            .bind(to: viewModel.didTapConfirm)
            .disposed(by: disposeBag)

        payDayPickerView.getCancelButton
            .rx.tap
            .bind(to: viewModel.didTapCancel)
            .disposed(by: disposeBag)
    }

    func setBinding() {
        payDayPickerView.getPickerView
            .rx.itemSelected
            .map { row, _ in row + 1 }
            .bind(to: viewModel.selectedDay)
            .disposed(by: disposeBag)

        viewModel.currentDay
            .drive(onNext: { [weak self] day in
                self?.payDayPickerView.select(day: day)
            })
            .disposed(by: disposeBag)

        viewModel.confirmSelectedDay
            .subscribe(onNext: { [weak self] selected in
                print("선택한 날짜: \(selected)")
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.dismiss
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
extension PayDayPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView( _ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView( _ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
}
