//
//  SignInViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let googleLoginTapped = PublishRelay<Void>()
    let googleLoginTriggered = PublishRelay<Void>()

    init() {
        configure()
    }
}

private extension SignInViewModel {
    // MARK: - configure
    func configure() {
        setBindings()
    }

    // MARK: - setBindings
    func setBindings() {
        googleLoginTapped.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.signInGoogle()
        })
        .disposed(by: disposeBag)
    }
}

private extension SignInViewModel {
    // MARK: - google SignIn
    func signInGoogle() { // TODO: - 러프하게 작성한 현 코드에 아키텍처 적용해야함
        googleLoginTriggered.accept(())
    }
}
