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
    private let rootView = OLDInviteCodeWorkplaceRegisterView()

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
            // 이 화면은 더 이상 어떤 Coordinator에서도 생성되지 않는 죽은 코드다(SwiftUI
            // InviteCodeWorkplaceRegisterView로 대체됨). InviteCodeInputCoordinator가
            // WorkplaceRegisterCoordinatorProtocol 채택을 그만두면서 생긴 타입 불일치를
            // 피하기 위해 nil을 넘긴다 — 실행되지 않는 경로라 동작에 영향 없다.
            coordinator: nil
        )
        self.workingConditionsContainerVC = WorkingConditionsContainerViewController(
            viewModel: viewModel.workingConditionsVM
        )
        self.colorLabelContainerVC = ColorLabelContainerViewController(
            viewModel: viewModel.colorLabelVM,
            coordinator: nil
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
        rootView.updateTitle(title: title ?? "초대코드 근무지 등록")
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
            })
            .disposed(by: disposeBag)
        
        rootView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapRegisterButton)
            .disposed(by: disposeBag)
        
        viewModel.didCompleteRegister
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                print("초대코드 근무지 등록 완료 → 홈 이동")
                self?.coordinator?.moveToHomeAfterJoin()
            })
            .disposed(by: disposeBag)
    }
}
