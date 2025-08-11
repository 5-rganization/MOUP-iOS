//
//  LogoutUseCase.swift
//  MOUP
//
//  Created by shinyoungkim on 8/11/25.
//

import RxSwift

// 임시
final class LogoutUseCase {
    func execute() -> Completable {
        return Single.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .asCompletable()
    }
}
