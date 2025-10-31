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
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let logoutConfirmed: Observable<Void>
    }
    
    // MARK: - Output
    
    struct Output {
        let profile: Driver<UserProfile?>
        let isLoading: Driver<Bool>
        let logoutSuccess: Signal<Void>
        let error: Signal<String>
    }
    
    // MARK: - Properties
    
    private let userUseCase: UserUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let profileRelay = BehaviorRelay<UserProfile?>(value: nil)
        let successRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<UserProfile?> in
                guard let self else { return .just(nil) }
                
                loadingRelay.accept(true)
                
                return Observable.create { observer in
                    Task {
                        do {
                            let profile = try await self.userUseCase.fetchProfile()
                            observer.onNext(profile)
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("프로필을 불러오는데 실패했습니다.")
                            observer.onNext(nil)
                            observer.onCompleted()
                        }
                        loadingRelay.accept(false)
                    }
                    return Disposables.create()
                }
            }
            .bind(to: profileRelay)
            .disposed(by: disposeBag)
        
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
            profile: profileRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            logoutSuccess: successRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
}
