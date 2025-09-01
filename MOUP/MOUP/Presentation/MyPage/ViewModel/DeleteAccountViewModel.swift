//
//  DeleteAccountViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/1/25.
//

import RxSwift
import RxCocoa

final class DeleteAccountViewModel {
    struct Input {
        let deleteTap: Observable<Void>
    }
    
    struct Output {
        let isDeleting: Driver<Bool>
        let deleteSuccess: Signal<Void>
        let errorMessage: Signal<String>
    }
    
    // MARK: - Properties
    
    private let isDeletingRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let successRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        
        input.deleteTap
            .flatMapLatest { [weak self] in
                guard let self else { return Observable<Event<Void>>.empty() }
                // TODO: - usecase 연결
                return Observable.just(())
                    .delay(.milliseconds(800), scheduler: MainScheduler.instance)
                    .do(onSubscribe: {
                        self.isDeletingRelay.accept(true)
                    }, onDispose: {
                        self.isDeletingRelay.accept(false)
                    })
                    .materialize()
            }
            .subscribe(onNext: { event in
                switch event {
                case .next:
                    break
                case .completed:
                    successRelay.accept(())
                case .error(let error):
                    errorRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            isDeleting: isDeletingRelay.asDriver(),
            deleteSuccess: successRelay.asSignal(),
            errorMessage: errorRelay.asSignal()
        )
    }
}
