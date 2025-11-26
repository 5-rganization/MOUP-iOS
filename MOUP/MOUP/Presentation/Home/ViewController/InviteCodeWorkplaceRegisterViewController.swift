//
//  InviteCodeWorkplaceRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class InviteCodeWorkplaceRegisterViewController: UIViewController {
    
    // MARK: - UI
    private let rootView = InviteCodeWorkplaceRegisterView()

    // MARK: - DI
    private let viewModel: InviteCodeWorkplaceRegisterViewModel
    private weak var coordinator: InviteCodeInputCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: - Container ViewControllers
    private let payContainerVC: PayContainerViewController
    private let workingConditionsContainerVC: WorkingConditionsContainerViewController
    private let colorLabelContainerVC: ColorLabelContainerViewController

    // MARK: - Init
    init(
        workplaceName: String,
        inviteCode: String,
        viewModel: InviteCodeWorkplaceRegisterViewModel,
        coordinator: InviteCodeInputCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator

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

        self.title = workplaceName
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewControllers()
        configure()
    }
}

// MARK: - Setup
private extension InviteCodeWorkplaceRegisterViewController {

    func addChildViewControllers() {
        add(child: payContainerVC, to: rootView.getPayContainerView)
        add(child: workingConditionsContainerVC, to: rootView.getWorkingConditionsContainerView)
        add(child: colorLabelContainerVC, to: rootView.getColorLabelContainerView)
    }

    func configure() {
        setStyles()
        setBinding()
    }
    
    func setStyles() {}
    
    func setBinding() {
        rootView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.isFormValid
            .drive(onNext: { [weak self] isValid in
                self?.rootView.getRegisterButton.isEnabled = isValid
                self?.rootView.getRegisterButton.update(
                    title: "등록",
                    isSecondary: !isValid
                )
            })
            .disposed(by: disposeBag)
        
        rootView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapRegisterButton)
            .disposed(by: disposeBag)
        
        viewModel.didCompleteRegister
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let coordinator = self?.coordinator?.homeCoordinator else { return }

                // 전체 스택을 홈 화면만 남기고 리셋
                self?.navigationController?.setViewControllers(
                    [UIViewController()], animated: false
                )

                coordinator.start()
            })
            .disposed(by: disposeBag)
    }
}
