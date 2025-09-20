//
//  NicknameViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import Foundation
import RxSwift
import RxRelay

final class NicknameViewModel {
    // MARK: - Properties
    let provider: LoginProvider
    private let disposeBag = DisposeBag()
    private let nicknameRelay = BehaviorRelay<String>(value: "")
    private let nicknameValidRelay = BehaviorRelay<Bool>(value: false)
    private let nicknameEditingStartedRelay = BehaviorRelay<Bool>(value: false)
    private let didTapNextRelay = PublishRelay<String>()

    // MARK: - Initializer
    init(provider: LoginProvider) {
        self.provider = provider
    }

    // MARK: - Input, Output
    struct Input {
        let nickname: Observable<String>
        let nextButtonTap: Observable<Void>
    }

    struct Output {
        let isValidNickname: Observable<Bool>
        let nicknameEditingStarted: Observable<Bool>
        let didTapNext: Observable<String> // 닉네임 방출
        let provider: Observable<LoginProvider>
    }

    // MARK: - transform
    func transform(input: Input) -> Output {
        input.nextButtonTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let nickname = owner.nicknameRelay.value
                owner.didTapNextRelay.accept(nickname)
            })
            .disposed(by: disposeBag)

        input.nickname
            .skip(1)
            .withUnretained(self)
            .subscribe(onNext: { owner, text in
                owner.nicknameRelay.accept(text)
                if !owner.nicknameEditingStartedRelay.value {
                    if text.count > 0 {
                        owner.nicknameEditingStartedRelay.accept(true)
                    }
                }
                let isValid = owner.isValidNickname(text)
                owner.nicknameValidRelay.accept(isValid)
            })
            .disposed(by: disposeBag)

        return Output(
            isValidNickname: nicknameValidRelay.asObservable(),
            nicknameEditingStarted: nicknameEditingStartedRelay.asObservable(),
            didTapNext: didTapNextRelay.asObservable(),
            provider: Observable.just(provider)
        )
    }
}

private extension NicknameViewModel {
    func isValidNickname(_ nickname: String) -> Bool {
        let pattern = "^[a-zA-z0-9가-힣]{1,8}$"
        let regex = try! Regex(pattern)
        return nickname.wholeMatch(of: regex) != nil // 문자열 전체가 조건에 부합하는지 확인
    }
}
