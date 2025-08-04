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
    private let googleAuthUseCase: GoogleAuthUseCaseProtocol

    let googleLoginTriggered = PublishRelay<SignInRequestDTO>()

    init(googleAuthUseCase: GoogleAuthUseCaseProtocol) {
        self.googleAuthUseCase = googleAuthUseCase
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
        googleLoginTriggered.subscribe(onNext: { [weak self] request in
            guard let self else { return }
            Task {
                let result = await self.googleAuthUseCase.signInWithGoogle(requestDTO: request)
                print(result)
            }
        })
        .disposed(by: disposeBag)
    }
}
