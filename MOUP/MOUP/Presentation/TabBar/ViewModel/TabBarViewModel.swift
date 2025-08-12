//
//  TabBarViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import RxSwift
import GoogleSignIn

final class TabBarViewModel {
    // MARK: - Properties
    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()

    private let signedUpResult = PublishSubject<Error?>()

    // MARK: - Initializer
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }

    struct Output {
        let isSignedUp: Observable<Error?> // 앞선 과정에서 액세스 토큰 만료 여부 확인됐으니 서버 내 회원 여부 확인
    }

    // MARK: - transform
    func transform(input: Input) -> Output {


        input.viewDidLoad.subscribe(onNext: { [weak self] _ in
            guard let idToken = GIDSignIn.sharedInstance.currentUser?.idToken else {
                return // TODO: - idToken 부재 시 재로그인 시킬 수 있도록 해야함. relay 등 이용 vc - coordinator 전파 필요
            }
            let signInRequestDTO = SignInRequestDTO(provider: "LOGIN_GOOGLE", idToken: idToken.tokenString)
            Task {
                guard let self else { return }
                do {
                    try await self.authUseCase.signInWithGoogle(requestDTO: signInRequestDTO)
                    self.signedUpResult.onNext(nil)
                } catch let error as NetworkError {
                    switch error {
                    case .serverError, .noResponse, .invalidResponse(_):
                        self.signedUpResult.onNext(error)
                    }
                } catch let error as AuthError {
                    switch error {
                    case .notMember:
                        self.signedUpResult.onNext(error)
                    }
                }
            }
        })
        .disposed(by: disposeBag)

        return Output(isSignedUp: signedUpResult.asObservable())
    }

}
