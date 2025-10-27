//
//  WorkplaceRegistrationSheetViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/17/25.
//

import UIKit
import RxSwift

class WorkplaceRegisterSheetViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: WorkplaceRegisterSheetCoordinator?
    private let disposeBag = DisposeBag()
    private let workplaceRegistrationSheetView = WorkplaceRegisterSheetView()
    
    // MARK: - loadView
    override func loadView() {
        view = workplaceRegistrationSheetView
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension WorkplaceRegisterSheetViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        workplaceRegistrationSheetView.rx.inviteCodeRegisterBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.dismiss(animated: true) { [weak self] in
                    guard let self else { return }
                    self.coordinator?.moveToInviteCodeInput()
                }
            })
            .disposed(by: disposeBag)
        
        workplaceRegistrationSheetView.rx.directRegisterBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.dismiss(animated: true) { [weak self] in
                    guard let self else { return }
                    self.coordinator?.moveToDirectRegistration()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension WorkplaceRegisterSheetViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinator?.sheetDismissed()
    }
}
