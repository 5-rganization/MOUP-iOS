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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.sheetDismissed()
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
                owner.coordinator?.moveToInviteCodeInput()
            })
            .disposed(by: disposeBag)
        
        workplaceRegistrationSheetView.rx.directRegisterBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.coordinator?.moveToDirectRegistration()
            })
            .disposed(by: disposeBag)
    }
}
