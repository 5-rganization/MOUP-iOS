//
//  UserRoleViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import Foundation
import RxSwift
import RxRelay

final class UserRoleViewModel {
    // MARK: - Properties
    private let nickname: String
    private let provider: LoginProvider
    private let authorizationCode: String
    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()
    private var selectedRoleRelay = BehaviorRelay<UserRole?>(value: nil)
    private let signupResultRelay = PublishRelay<Bool>()
    private let didTapStartRelay = PublishRelay<Void>()
    let signUpTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Initializer
    init(nickname: String, authorizationCode: String, provider: LoginProvider, authUseCase: AuthUseCaseProtocol) {
        self.nickname = nickname
        self.authorizationCode = authorizationCode
        self.provider = provider
        self.authUseCase = authUseCase
        print("userRoleViewModel - nickname: \(nickname)주입받음")
        setBindings()
    }

    // MARK: - Input, Output
    struct Input {
        let selectedRole: Observable<UserRole?>
        let startButtonTap: Observable<Void>
    }

    struct Output {
        let selectedRole: Observable<UserRole?>
        let didTapStart: Observable<Void>
        let signUpResult: Observable<Bool>
    }

    // MARK: - transform
    func transform(input: Input) -> Output {
        input.selectedRole
            .withUnretained(self)
            .subscribe(onNext: { owner, userRole in
                owner.selectedRoleRelay.accept(userRole)
            })
            .disposed(by: disposeBag)

        input.startButtonTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.didTapStartRelay.accept(())
            })
            .disposed(by: disposeBag)

        return Output(
            selectedRole: selectedRoleRelay.asObservable(),
            didTapStart: didTapStartRelay.asObservable(),
            signUpResult: signupResultRelay.asObservable()
        )
    }

}

private extension UserRoleViewModel {
    func setBindings() {
        signUpTriggerRelay
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.signUp()
            })
            .disposed(by: disposeBag)
    }

    func signUp() {
        print("회원가입 시작")
        guard let userRole = selectedRoleRelay.value else {
            return
        }

        Task {
            do {
                try await authUseCase.signUp(
                    requestDTO: RegisterRequestDTO(
                        provider: provider.rawValue,
                        authCode: authorizationCode,
                        username: "",
                        nickname: nickname,
                        role: userRole.rawValue
                    )
                )
                signupResultRelay.accept(true)
            } catch {
                signupResultRelay.accept(false)
            }
        }
    }
}
