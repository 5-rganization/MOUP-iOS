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
    case showAlert((title: String, message: String))
}

final class SignInViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let authUseCase: AuthUseCaseProtocol
    
    let googleLoginTriggered = PublishRelay<Void>()
    let appleLoginTriggered = PublishRelay<Void>()
    let signInOutputEventRelay = PublishRelay<SignInOutputEvent>()
    let loginProviderRelay = BehaviorRelay<LoginProvider?>(value: nil)
    
    // MARK: - Input, Output
    struct Input {
        let googleLoginTap: Observable<Void>
        let appleLoginTap: Observable<Void>
        let authResult: Observable<(provider: LoginProvider?, username: String, authCode: String)>
    }
    
    struct Output {
        let startGoogleLogin: Observable<Void>
        let startAppleLogin: Observable<Void>
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
        
        input.appleLoginTap.subscribe(with: self) { owner, _ in
            owner.appleLoginTriggered.accept(())
        }.disposed(by: disposeBag)
        
        input.authResult.subscribe(
            with: self,
            onNext: {
                owner,
                result in
                let (provider, username, authCode) = result
                
                guard let provider else { return }
                if authCode == "" { return }
                Task {
                    do {
                        try await self.authUseCase.signIn(
                            requestDTO: LoginRequestDTO(
                                provider: provider.rawValue,
                                authCode: authCode,
                                username: username,
                                fcmToken: UserDefaultsManager.shared.fcmToken ?? ""
                            )
                        )
                        self.signInOutputEventRelay.accept(SignInOutputEvent.loginSuccessed)
                    } catch let error as NetworkError {
                        let errorInfo: (title: String, message: String)
                        switch error {
                        case .serverError:
                            errorInfo = (title: "서버 오류", message: error.localizedDescription)
                        case .noResponse,
                                .invalidResponse:
                            errorInfo = (title: "예상치 못한 오류", message: error.localizedDescription)
                        }
                        self.signInOutputEventRelay.accept(.showAlert(errorInfo))
                    } catch let error as AuthError {
                        switch error {
                        case .notMember:
                            self.loginProviderRelay.accept(provider)
                            self.signInOutputEventRelay.accept(SignInOutputEvent.navigateToSignUp)
                        default:
                            self.signInOutputEventRelay.accept(
                                .showAlert(
                                    (
                                        title: "로그인 실패",
                                        message: error.localizedDescription
                                    )
                                )
                            )
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        return Output(
            startGoogleLogin: googleLoginTriggered.asObservable(),
            startAppleLogin: appleLoginTriggered.asObservable(),
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
