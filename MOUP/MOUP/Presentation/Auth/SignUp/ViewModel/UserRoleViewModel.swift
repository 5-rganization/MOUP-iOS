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
    private let disposeBag = DisposeBag()
    private let nickname: String
    private var selectedRoleRelay = BehaviorRelay<UserRole?>(value: nil)
    private let signupResultRelay = PublishRelay<Bool>()
    private let didTapStartRelay = PublishRelay<Void>()

    // MARK: - Initializer
    init(nickname: String) {
        self.nickname = nickname
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
                print("selectedRole(VM) 설정됨 : \(owner.selectedRoleRelay.value)")
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
    func signUp() {
        print("회원가입 탭")
        signupResultRelay.accept(false)
    }
}
