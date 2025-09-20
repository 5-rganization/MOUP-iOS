//
//  TabBarViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import RxSwift

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

        })
        .disposed(by: disposeBag)

        return Output(isSignedUp: signedUpResult.asObservable())
    }

}
