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
    func setHierarchy() {
        view.addSubview(workingConditionsContainerView)
    }
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
        let view = workingConditionsContainerView
        
        view.getFourMajorSocialInsurancesInfoRow.rx.tap
            .bind(to: viewModel.toggleFourMajorInsurance)
            .disposed(by: disposeBag)
        
        view.getNationalPensionInfoRow.rx.tap
            .bind(to: viewModel.toggleNationalPension)
            .disposed(by: disposeBag)
        
        view.getNationalHealthInsuranceInfoRow.rx.tap
            .bind(to: viewModel.toggleHealthInsurance)
            .disposed(by: disposeBag)
        
        view.getEmploymentInsuranceInfoRow.rx.tap
            .bind(to: viewModel.toggleEmploymentInsurance)
            .disposed(by: disposeBag)
        
        view.getIndustrialAccidentCompensationInsuranceInfoRow.rx.tap
            .bind(to: viewModel.toggleIndustrialAccidentInsurance)
            .disposed(by: disposeBag)
        
        view.getIncomeTaxInfoRow.rx.tap
            .bind(to: viewModel.toggleIncomeTaxInsurance)
            .disposed(by: disposeBag)
        
        view.getWeeklyHolidayAllowanceInfoRow.rx.tap
            .bind(to: viewModel.toggleWeeklyHolidayAllowanceInsurance)
            .disposed(by: disposeBag)
        
        view.getNightShiftAllowanceInfoRow.rx.tap
            .bind(to: viewModel.toggleNightShiftAllowanceInsurance)
            .disposed(by: disposeBag)
        
        viewModel.isFourMajorInsuranceChecked
            .bind(to: view.getFourMajorSocialInsurancesInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isNationalPensionChecked
            .bind(to: view.getNationalPensionInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isHealthInsuranceChecked
            .bind(to: view.getNationalHealthInsuranceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isEmploymentInsuranceChecked
            .bind(to: view.getEmploymentInsuranceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isIndustrialAccidentInsuranceChecked
            .bind(to: view.getIndustrialAccidentCompensationInsuranceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isIncomeTaxInsuranceChecked
            .bind(to: view.getIncomeTaxInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isWeeklyHolidayAllowanceInsuranceChecked
            .bind(to: view.getWeeklyHolidayAllowanceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
        
        viewModel.isNightShiftAllowanceInsuranceChecked
            .bind(to: view.getNightShiftAllowanceInfoRow.rx.isChecked)
            .disposed(by: disposeBag)
    }
    
}
