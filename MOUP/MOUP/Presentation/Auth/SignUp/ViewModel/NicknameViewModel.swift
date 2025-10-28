//
//  NicknameViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import Foundation
import OSLog

import RxSwift
import RxRelay

final class NicknameViewModel {
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
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
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            let message = "한글, 영문 또는 숫자만 사용하여 8자 이하로 입력해주세요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        if nickname.contains(where: { $0.isWhitespace }) {
            let message = "공백은 사용할 수 없어요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        if trimmed.range(of: "^[ㄱ-ㅎ]+$", options: .regularExpression) != nil {
            let message = "자음만 사용할 수 없어요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        if trimmed.range(of: "^[ㅏ-ㅣ]+$", options: .regularExpression) != nil {
            let message = "모음만 사용할 수 없어요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        if trimmed.range(of: "[ㄱ-ㅎㅏ-ㅣ]", options: .regularExpression) != nil {
            let message = "정확한 글자를 입력해주세요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        let containsHangul = trimmed.range(of: "[가-힣]", options: .regularExpression) != nil
        let containsAlphabet = trimmed.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        if containsHangul && containsAlphabet {
            let message = "한글 또는 영문만 사용할 수 있어요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        if trimmed.range(of: "[^가-힣a-zA-Z0-9]", options: .regularExpression) != nil {
            let message = "특수문자는 사용할 수 없어요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        if trimmed.count > 8 {
            let message = "8자 이하로 입력해주세요"
            logger.info("닉네임 검증 실패: \(message)")
            return false
        }
        
        // 모든 검증을 통과하면 true를 반환
        return true
    }
}
