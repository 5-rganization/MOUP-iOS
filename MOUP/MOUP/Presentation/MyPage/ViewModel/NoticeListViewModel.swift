//
//  NoticeListViewModel.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation
import RxSwift
import RxCocoa

final class NoticeListViewModel {
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output
    
    struct Output {
        let notices: Driver<[Notice]>
        let isLoading: Driver<Bool>
        let error: Signal<String>
    }
    
    // MARK: - Properties
    
    private let noticeUseCase: NoticeUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(noticeUseCase: NoticeUseCaseProtocol) {
        self.noticeUseCase = noticeUseCase
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let noticesRelay = BehaviorRelay<[Notice]>(value: [])
        let errorRelay = PublishRelay<String>()
        
        input.viewDidLoad
            .do(onNext: { _ in
                loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[Notice]> in
                guard let self else { return .just([]) }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let notices = try await self.noticeUseCase.fetchNotices()
                            observer.onNext(notices)
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("공지사항을 불러오는데 실패했습니다.")
                            observer.onNext([])
                            observer.onCompleted()
                        }
                        loadingRelay.accept(false)
                    }
                    return Disposables.create()
                }
            }
            .bind(to: noticesRelay)
            .disposed(by: disposeBag)
        
        return Output(
            notices: noticesRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }
}
