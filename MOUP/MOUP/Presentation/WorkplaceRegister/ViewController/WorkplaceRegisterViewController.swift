//
//  WorkplaceRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class WorkplaceRegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let workplaceRegisterView = WorkplaceRegisterView()
    
    private let viewModel: WorkplaceRegisterViewModel
    private let coordinator: WorkplaceRegisterCoordinatorProtocol
    private let disposeBag = DisposeBag()
    
    private let workplaceContainerVC: WorkplaceContainerViewController
    private let payContainerVC: PayContainerViewController
    private let workingConditionsContainerVC: WorkingConditionsContainerViewController
    private let colorLabelContainerVC: ColorLabelContainerViewController

    // MARK: - Initializer
    init(
        viewModel: WorkplaceRegisterViewModel,
        coordinator: WorkplaceRegisterCoordinatorProtocol
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        // Container VC들은 ViewModel 내부 속성으로부터 생성
        self.workplaceContainerVC = WorkplaceContainerViewController(
            viewModel: viewModel.workplaceVM,
            coordinator: coordinator
        )
        self.payContainerVC = PayContainerViewController(
            viewModel: viewModel.payVM,
            coordinator: coordinator
        )
        self.workingConditionsContainerVC = WorkingConditionsContainerViewController(
            viewModel: viewModel.workingConditionsVM
        )
        self.colorLabelContainerVC = ColorLabelContainerViewController(
            viewModel: viewModel.colorLabelVM,
            coordinator: coordinator
        )
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("Storyboard is not supported")
    }

    // MARK: - Lifecycle
    override func loadView() {
        self.view = workplaceRegisterView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add(child: workplaceContainerVC, to: workplaceRegisterView.getWorkplaceContainerView)
        add(child: payContainerVC, to: workplaceRegisterView.getPayContainerView)
        add(child: workingConditionsContainerVC, to: workplaceRegisterView.getWorkingConditionsContainerView)
        add(child: colorLabelContainerVC, to: workplaceRegisterView.getColorLabelContainerView)
        configure()
    }

    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UI Methods

private extension WorkplaceRegisterViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }

    func setHierarchy() { }
    func setStyles() {
        setNavigationBar(
            title: "새 근무지 등록",
            backAction: #selector(didTapBack)
        )
    }

    func setConstraints() { }
    func setActions() { }

    func setBinding() {
        
        viewModel.isFormValid
            .drive(onNext: { [weak self] isValid in
                self?.workplaceRegisterView.getRegisterButton.isEnabled = isValid
                self?.workplaceRegisterView.getRegisterButton.update(title: "완료", isSecondary: false)
            })
            .disposed(by: disposeBag)
        
        workplaceRegisterView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)

        viewModel.didCompleteRegister
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                print("등록된 근무지 데이터: \(data)")
                // TODO: 등록 완료 후 화면 종료나 다음 화면 이동 처리
            })
            .disposed(by: disposeBag)
    }
}
