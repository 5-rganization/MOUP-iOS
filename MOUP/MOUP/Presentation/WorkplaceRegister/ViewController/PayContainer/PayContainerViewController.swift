//
//  PayContainerViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import RxSwift

final class PayContainerViewController: UIViewController {
    
    // MARK: - Properties
    private let payContainerView = PayContainerView()
    private let viewModel: PayContainerViewModel
    private let disposeBag = DisposeBag()
    
    weak var coordinator: WorkplaceRegisterCoordinatorProtocol?
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = payContainerView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(
        viewModel: PayContainerViewModel,
        coordinator: WorkplaceRegisterCoordinatorProtocol?
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UI Methods

private extension PayContainerViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() { }
    func setConstraints() { }
    func setActions() { }
    func setBinding() {
        payContainerView.getPayTypeInfoRow.rx.tap
            .bind(to: viewModel.didTapPayType)
            .disposed(by: disposeBag)
        payContainerView.getPayCalculationInfoRow.rx.tap
            .bind(to: viewModel.didTapPayCalculation)
            .disposed(by: disposeBag)
        payContainerView.getSalaryTypeInfoRow.rx.tap
            .bind(to: viewModel.didTapSalaryType)
            .disposed(by: disposeBag)

        viewModel.showPayType
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showSelectPayType()
            })
            .disposed(by: disposeBag)
        viewModel.showPayCalculation
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showSelectPayCalculation()
            })
            .disposed(by: disposeBag)
        viewModel.showSalaryType
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showInputSalaryType()
            })
            .disposed(by: disposeBag)
    }
    
}
