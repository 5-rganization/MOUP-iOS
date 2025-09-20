//
//  NicknameViewController.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit
import RxSwift

class NicknameViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let nicknameView = NicknameView()
    private let nicknameViewModel: NicknameViewModel
    weak var coordinator: SignUpCoordinator?

    // MARK: - loadView
    override func loadView() {
        view = nicknameView
    }

    // MARK: - Initializer
    init(nicknameViewModel: NicknameViewModel) {
        self.nicknameViewModel = nicknameViewModel
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

private extension NicknameViewController {
    // MARK: - configure
    func configure() {
        setBindings()
        setNavigationBar(title: "닉네임 설정")
    }

    // MARK: - setBindings
    func setBindings() {
        let input = NicknameViewModel.Input(
            nickname: nicknameView.rx.nicknameText.asObservable(),
            nextButtonTap: nicknameView.rx.startButtonTap.asObservable()
        )
        let output = nicknameViewModel.transform(input: input)

        Observable
            .combineLatest(output.isValidNickname, output.nicknameEditingStarted)
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { owner, tuple in // tuple - 0: isValid, 1: isEditingStarted
                if tuple.1 {
                    owner.nicknameView.update(isValid: tuple.0)
                }
            })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(output.didTapNext, output.provider)
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { owner, tuple in // tuple - 0: String(nickname), 1: provider
                owner.coordinator?.goToSetUserRole(with: tuple.0, provider: tuple.1)
            })
            .disposed(by: disposeBag)
    }

}
