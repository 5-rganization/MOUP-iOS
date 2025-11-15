//
//  InviteCodeResultViewController.swift
//  MOUP
//
//  Created by 송규섭 on 11/3/25.
//

import UIKit
import RxSwift

class InviteCodeResultViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let inviteCodeResultView = InviteCodeResultView()
    private let viewModel: InviteCodeResultViewModel
    private let coordinator: InviteCodeInputCoordinator
    
    // MARK: - loadView
    override func loadView() {
        view = inviteCodeResultView
    }
    
    // MARK: - Initializer
    init(viewModel: InviteCodeResultViewModel, coordinator: InviteCodeInputCoordinator) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
   
}

private extension InviteCodeResultViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        let input = InviteCodeResultViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.workplace
            .withUnretained(self)
            .subscribe(onNext: { owner, workplace in
                owner.inviteCodeResultView.update(with: workplace)
            })
            .disposed(by: disposeBag)
        
        inviteCodeResultView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        inviteCodeResultView.rx.registerInfoBtnTapped // TODO: - workplacename, inviteCode 넘겨주기
            .withLatestFrom(output.workplace)
            .withUnretained(self)
            .subscribe(
                onNext: { owner, workplace in
                    print("등록하기 버튼 탭")
                    owner.coordinator.moveToInviteCodeWorkplaceRegister(
                        workplaceName: workplace.workplaceName,
                        inviteCode: output.inviteCode
                    )
            })
            .disposed(by: disposeBag)
    }
}
