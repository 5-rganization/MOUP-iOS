//
//  SelectPayTypeViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class SelectPayTypeViewController: UIViewController {
    
    // MARK: - Properties
    private let selectPayTypeView = SelectPayTypeView()
    private let viewModel: SelectPayTypeViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectPayTypeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetToConfirmedPayTypeIfNeeded()
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: SelectPayTypeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UI Methods

private extension SelectPayTypeViewController {
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
        let radioButtons: [(OLDRadioButtonView, String)] = [
            (selectPayTypeView.getMonthlyRadioButton, SalaryType.monthly.displayText),
            (selectPayTypeView.getWeeklyRadioButton, SalaryType.weekly.displayText),
            (selectPayTypeView.getDailyRadioButton, SalaryType.daily.displayText)
        ]

        radioButtons.forEach { (button, type) in
            button.rx.tap
                .bind { [weak self] in
                    self?.viewModel.didSelectPayType.onNext(type)
                }
                .disposed(by: disposeBag)
        }

        selectPayTypeView.getRegisterButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.didTapConfirm.onNext(())
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    func setBinding() {
        selectPayTypeView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.viewModel.resetSelectedPayType()
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        let radioButtons: [(OLDRadioButtonView, String)] = [
            (selectPayTypeView.getMonthlyRadioButton, SalaryType.monthly.displayText),
            (selectPayTypeView.getWeeklyRadioButton, SalaryType.weekly.displayText),
            (selectPayTypeView.getDailyRadioButton, SalaryType.daily.displayText)
        ]

        viewModel.isPayTypeSelected
            .drive(onNext: { [weak self] isSelected in
                self?.selectPayTypeView.getRegisterButton.isEnabled = isSelected
            })
            .disposed(by: disposeBag)

        viewModel.selectedPayType
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { selected in
                radioButtons.forEach { (button, type) in
                    button.setSelected(type == selected)
                }
            }
            .disposed(by: disposeBag)

        viewModel.confirmedPayType
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
