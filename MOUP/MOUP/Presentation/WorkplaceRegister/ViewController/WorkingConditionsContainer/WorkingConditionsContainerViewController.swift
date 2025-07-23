//
//  WorkingConditionsContainerViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/23/25.
//

import UIKit
import RxSwift

final class WorkingConditionsContainerViewController: UIViewController {
    
    // MARK: - Properties
    private let workingConditionsContainerView = WorkingConditionsContainerView()
    private let viewModel: WorkingConditionsContainerViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = workingConditionsContainerView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: WorkingConditionsContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UI Methods

private extension WorkingConditionsContainerViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() {
        view.backgroundColor = .white
    }
    func setConstraints() {
        workingConditionsContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    func setActions() { }
    func setBinding() {
        workingConditionsContainerView.getFourMajorSocialInsurancesInfoRow.rx.tap
            .bind(to: viewModel.toggleFourMajorInsurance)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getNationalPensionInfoRow.rx.tap
            .bind(to: viewModel.toggleNationalPension)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getNationalHealthInsuranceInfoRow.rx.tap
            .bind(to: viewModel.toggleHealthInsurance)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getEmploymentInsuranceInfoRow.rx.tap
            .bind(to: viewModel.toggleEmploymentInsurance)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getIndustrialAccidentCompensationInsuranceInfoRow.rx.tap
            .bind(to: viewModel.toggleIndustrialAccidentInsurance)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getIncomeTaxInfoRow.rx.tap
            .bind(to: viewModel.toggleIncomeTaxInsurance)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getWeeklyHolidayAllowanceInfoRow.rx.tap
            .bind(to: viewModel.toggleWeeklyHolidayAllowanceInsurance)
            .disposed(by: disposeBag)
        
        workingConditionsContainerView.getNightShiftAllowanceInfoRow.rx.tap
            .bind(to: viewModel.toggleNightShiftAllowanceInsurance)
            .disposed(by: disposeBag)
        
        viewModel.isFourMajorInsuranceChecked
            .bind(to: workingConditionsContainerView.getFourMajorSocialInsurancesInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isNationalPensionChecked
            .bind(to: workingConditionsContainerView.getNationalPensionInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isHealthInsuranceChecked
            .bind(to: workingConditionsContainerView.getNationalHealthInsuranceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isEmploymentInsuranceChecked
            .bind(to: workingConditionsContainerView.getEmploymentInsuranceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isIndustrialAccidentInsuranceChecked
            .bind(to: workingConditionsContainerView.getIndustrialAccidentCompensationInsuranceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isIncomeTaxInsuranceChecked
            .bind(to: workingConditionsContainerView.getIncomeTaxInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isWeeklyHolidayAllowanceInsuranceChecked
            .bind(to: workingConditionsContainerView.getWeeklyHolidayAllowanceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isNightShiftAllowanceInsuranceChecked
            .bind(to: workingConditionsContainerView.getNightShiftAllowanceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
    }
}
