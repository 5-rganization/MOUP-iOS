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
    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(
        userUseCase: UserUseCaseProtocol,
        authUseCase: AuthUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
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
            .do(onNext: { _ in
                loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<Result<Void, Error>> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.authUseCase.logout()
                            observer.onNext(.success(()))
                            observer.onCompleted()
                        } catch {
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                        }
                        loadingRelay.accept(false)
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    successRelay.accept(())
                case .failure(let error):
                    errorRelay.accept("로그아웃에 실패했습니다. 잠시 후 다시 시도해주세요.")
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
