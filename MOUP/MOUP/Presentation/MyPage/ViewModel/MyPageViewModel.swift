//
//  MyPageViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel {
    
    struct Input {
        let logoutConfirmed: Observable<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let logoutSuccess: Signal<Void>
        let error: Signal<String>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let successRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        
        input.logoutConfirmed
            .flatMapLatest {
                // TODO: - usecase 연결
                Observable<Void>.create { observer in
                    loadingRelay.accept(true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        observer.onNext(())
                        observer.onCompleted()
                        loadingRelay.accept(false)
                    }
                    
                    return Disposables.create()
                }
                .materialize()
            }
            .subscribe(onNext: { event in
                switch event {
                case .next:
                    successRelay.accept(())
                case .error(let error):
                    errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: loadingRelay.asDriver(),
            logoutSuccess: successRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
}
