//
//  SignInViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - SignInOutputEvent
enum SignInOutputEvent {
    case navigateToSignUp
    case showAlert(Error)
}

final class SignInViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let googleAuthUseCase: GoogleAuthUseCaseProtocol

    let googleLoginTriggered = PublishRelay<SignInRequestDTO>()
    let signInOutputEventRelay = PublishRelay<SignInOutputEvent>()

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
                do {
                    try await self.googleAuthUseCase.signInWithGoogle(requestDTO: request)
                } catch let error as NetworkError {
                    switch error {
                    case .serverError, .noResponse, .invalidResponse(_):
                        self.signInOutputEventRelay.accept(SignInOutputEvent.showAlert(error))
                    }
                } catch let error as AuthError {
                    switch error {
                    case .notMember:
                        self.signInOutputEventRelay.accept(SignInOutputEvent.navigateToSignUp)
                    }
                }
            }
        })
        .disposed(by: disposeBag)
    }
}
