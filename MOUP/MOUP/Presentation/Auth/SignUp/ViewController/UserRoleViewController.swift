//
//  UserRoleViewController.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit
import RxSwift
import RxRelay

class UserRoleViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: SignUpCoordinator?
    private let userRoleView = UserRoleView()
    private let disposeBag = DisposeBag()
    private let userRoleViewModel: UserRoleViewModel

    // MARK: - loadView
    override func loadView() {
        view = userRoleView
    }

    // MARK: - Initializer
    init(userRoleViewModel: UserRoleViewModel) {
        self.userRoleViewModel = userRoleViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension UserRoleViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }

    // MARK: - setBindings
    func setBindings() {
        let input = UserRoleViewModel.Input(
            selectedRole: userRoleView.rx.selectedRole,
            startButtonTap: userRoleView.rx.startButtonTap.asObservable()
        )
        let output = userRoleViewModel.transform(input: input)

        output.didTapStart
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("시작하기 탭")
            })
            .disposed(by: disposeBag)

        output.signUpResult
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                if result {
                    print("회원가입 성공")
                    owner.coordinator?.didFinishSignUp()
                } else {
                    print("회원가입 실패")
                }
            })
            .disposed(by: disposeBag)
    }
}
