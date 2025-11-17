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
        
        // Owner 전용 VC
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
    
    @available(*, unavailable, message: "Storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
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
    
    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - UI Setup
private extension OwnerWorkplaceRegisterViewController {
    
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    func setHierarchy() { }
    
    func setStyles() { }
    
    func setConstraints() { }
    
    func setActions() { }
    
    // MARK: - Binding
    func setBinding() {
        ownerView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        // 버튼 활성화
        viewModel.isFormValid
            .drive(onNext: { [weak self] isValid in
                self?.ownerView.getRegisterButton.isEnabled = isValid
                self?.ownerView.getRegisterButton.update(title: "완료", isSecondary: false)
            })
            .disposed(by: disposeBag)
        
        // 등록 버튼 실행
        ownerView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapCompleteButton)
            .disposed(by: disposeBag)
        
        // 등록 완료 후 pop
        viewModel.didCompleteRegister
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] workplaceId in
                print("매장 등록 성공 - workplaceId: \(workplaceId)")
                self?.navigationController?.popViewController(animated: true)
                
            }, onError: { error in
                if let workplaceError = error as? WorkplaceError {
                    print("매장 등록 실패 - \(workplaceError.debugDescription ?? "알 수 없는 에러")")
                } else {
                    print("매장 등록 실패 - \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
