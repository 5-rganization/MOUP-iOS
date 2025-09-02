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
    private let authUseCase: AuthUseCaseProtocol

    let googleLoginTriggered = PublishRelay<Void>()
    let signInOutputEventRelay = PublishRelay<SignInOutputEvent>()

    // MARK: - Input, Output
    struct Input {
        let googleLoginTap: Observable<Void>
        let googleAuthCode: Observable<String>
    }

    struct Output {
        let startGoogleLogin: Observable<Void>
        let signInResult: Observable<SignInOutputEvent> // TODO: - 테스트 성공 후 ResponseDTO로 이전
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
            Task {
                do {
                    try await self.authUseCase.signIn(requestDTO: LoginRequestDTO(provider: "LOGIN_GOOGLE", authCode: code))
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

        return Output(
            startGoogleLogin: googleLoginTriggered.asObservable(),
            signInResult: signInOutputEventRelay.asObservable()
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
