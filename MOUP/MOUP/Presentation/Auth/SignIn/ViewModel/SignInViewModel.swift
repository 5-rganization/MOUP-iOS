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
    case loginSuccessed
    case navigateToSignUp
    case showAlert(Error)
}

final class SignInViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let authUseCase: AuthUseCaseProtocol

    let googleLoginTriggered = PublishRelay<Void>()
    let signInOutputEventRelay = PublishRelay<SignInOutputEvent>()
    let loginProviderRelay = BehaviorRelay<LoginProvider?>(value: nil)

    // MARK: - Input, Output
    struct Input {
        let googleLoginTap: Observable<Void>
        let googleAuthCode: Observable<String>
    }

    struct Output {
        let startGoogleLogin: Observable<Void>
        let signInResult: Observable<SignInOutputEvent>
        let loginProvider: Observable<LoginProvider?>
    }

    // MARK: - Initializer
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
        configure()
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        input.googleLoginTap.subscribe(onNext: {
            self.googleLoginTriggered.accept(())
        })
        .disposed(by: disposeBag)

        input.googleAuthCode.subscribe(onNext: { code in
            if code == "" { return }
            Task {
                do {
                    try await self.authUseCase.signIn(requestDTO: LoginRequestDTO(provider: LoginProvider.google.rawValue, authCode: code))
                    self.signInOutputEventRelay.accept(SignInOutputEvent.loginSuccessed)
                } catch let error as NetworkError {
                    switch error {
                    case .serverError, .noResponse, .invalidResponse(_):
                        self.signInOutputEventRelay.accept(SignInOutputEvent.showAlert(error))
                    }
                } catch let error as AuthError {
                    switch error {
                    case .notMember:
                        self.loginProviderRelay.accept(.google)
                        self.signInOutputEventRelay.accept(SignInOutputEvent.navigateToSignUp)
                    default:
                        return
                    }
                }
            }
        })
        .disposed(by: disposeBag)

        return Output(
            startGoogleLogin: googleLoginTriggered.asObservable(),
            signInResult: signInOutputEventRelay.asObservable(),
            loginProvider: loginProviderRelay.asObservable()
        )
    }
}

private extension SignInViewModel {
    // MARK: - configure
    func configure() {
        setBindings()
    }

    // MARK: - setBindings
    func setBindings() {

    }
}
