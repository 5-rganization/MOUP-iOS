//
//  MyPageViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import RxSwift
import RxCocoa

protocol MyPageViewModelInput {
    var logoutConfirmed: AnyObserver<Void> { get }
}

protocol MyPageViewModelOutput {
    var isLoading: Driver<Bool> { get }
    var logoutSuccess: Signal<Void> { get }
    var error: Signal<String> { get }
}

final class MyPageViewModel: MyPageViewModelInput, MyPageViewModelOutput {
    
    // MARK: - Input
    
    private let logoutConfirmedSubject = PublishSubject<Void>()
    var logoutConfirmed: AnyObserver<Void> { logoutConfirmedSubject.asObserver() }
    
    // MARK: - Output
    
    let isLoading: Driver<Bool>
    let logoutSuccess: Signal<Void>
    let error: Signal<String>
    
    private let disposeBag = DisposeBag()
    
    init(logoutUseCase: LogoutUseCase) {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let successRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        
        self.isLoading = loadingRelay.asDriver()
        self.logoutSuccess = successRelay.asSignal()
        self.error = errorRelay.asSignal()
        
        logoutConfirmedSubject
            .flatMapLatest {
                logoutUseCase.execute()
                    .do(
                        onSubscribe: { loadingRelay.accept(true) },
                        onDispose: { loadingRelay.accept(false) }
                    )
                    .andThen(Observable.just(()))
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
    }
}
