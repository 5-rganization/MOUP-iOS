//
//  OwnerWorkplaceRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class OwnerWorkplaceRegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let ownerView = OwnerWorkplaceRegisterView()
    
    private let viewModel: OwnerWorkplaceRegisterViewModel
    private let coordinator: WorkplaceRegisterCoordinatorProtocol
    private let disposeBag = DisposeBag()

    private let ownerWorkplaceContainerVC: OwnerWorkplaceContainerViewController
    private let colorLabelContainerVC: ColorLabelContainerViewController
    
    // MARK: - Initializer
    init(
        viewModel: OwnerWorkplaceRegisterViewModel,
        coordinator: WorkplaceRegisterCoordinatorProtocol
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        self.ownerWorkplaceContainerVC = OwnerWorkplaceContainerViewController(
            viewModel: viewModel.workplaceVM,
            coordinator: coordinator
        )
        
        self.colorLabelContainerVC = ColorLabelContainerViewController(
            viewModel: viewModel.colorLabelVM,
            coordinator: coordinator
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = ownerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(child: ownerWorkplaceContainerVC, to: ownerView.getOwnerWorkplaceContainerView)
        add(child: colorLabelContainerVC, to: ownerView.getColorLabelContainerView)
        
        configure()
    }
}

private extension OwnerWorkplaceRegisterViewController {
    
    func configure() {
        setBinding()

        // 버튼 텍스트 모드에 따라 변경
        switch viewModel.mode {
        case .create:
            ownerView.getNavigationBar.configureTitle(title: "새 근무지 등록")
            ownerView.getRegisterButton.setTitle("등록하기", for: .normal)
        case .edit:
            ownerView.getNavigationBar.configureTitle(title: "근무지 수정")
            ownerView.getRegisterButton.setTitle("수정하기", for: .normal)
        }
    }
    
    // MARK: - Binding
    func setBinding() {
        ownerView.rx.navBackBtnTapped
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 버튼 활성화
        viewModel.isFormValid
            .drive(ownerView.getRegisterButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 등록/수정 버튼 공통
        ownerView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)
        
        // 완료 후 pop
        viewModel.didCompleteRegister
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] workplaceId in
                print("완료: workplaceId = \(workplaceId)")
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
