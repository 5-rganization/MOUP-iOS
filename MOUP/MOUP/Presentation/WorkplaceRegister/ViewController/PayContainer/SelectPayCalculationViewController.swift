//
//  SelectPayCalculationViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class SelectPayCalculationViewController: UIViewController {
    
    // MARK: - Properties
    private let selectPayCalculationView = SelectPayCalculationView()
    private let viewModel: SelectPayCalculationViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectPayCalculationView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetToConfirmedPayCalculationIfNeeded()
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: SelectPayCalculationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UI Methods

private extension SelectPayCalculationViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() {}
    func setConstraints() { }
    func setActions() {
        let radioButtons: [(RadioButtonView, String)] = [
            (selectPayCalculationView.getHourlyRadioButton, "시급"),
            (selectPayCalculationView.getFixedRadioButton, "고정급"),
        ]

        radioButtons.forEach { (button, type) in
            button.rx.tap
                .bind { [weak self] in
                    self?.viewModel.didSelectPayCalculation.onNext(type)
                }
                .disposed(by: disposeBag)
        }

        selectPayCalculationView.getRegisterButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.didTapConfirm.onNext(())
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    func setBinding() {
        selectPayCalculationView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.viewModel.resetSelectedPayCalculation()
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        let radioButtons: [(RadioButtonView, String)] = [
            (selectPayCalculationView.getHourlyRadioButton, "시급"),
            (selectPayCalculationView.getFixedRadioButton, "고정급"),
        ]
        viewModel.isPayCalculationSelected
            .drive(onNext: { [weak self] isSelected in
                self?.selectPayCalculationView.getRegisterButton.isEnabled = isSelected
            })
            .disposed(by: disposeBag)

        viewModel.selectedPayCalculation
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { selected in
                radioButtons.forEach { (button, type) in
                    button.setSelected(type == selected)
                }
            }
            .disposed(by: disposeBag)

        viewModel.confirmedPayCalculation
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { confirmed in
                radioButtons.forEach { (button, type) in
                    button.setSelected(type == confirmed)
                }
            }
            .disposed(by: disposeBag)
    }
    
}
