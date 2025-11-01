//
//  DeleteAccountViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/1/25.
//

import RxSwift
import RxCocoa

final class DeleteAccountViewModel {
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let deleteTap: Observable<Void>
    }
    
    // MARK: - Output
    
    struct Output {
        let nickname: Driver<String>
        let isDeleting: Driver<Bool>
        let deleteSuccess: Signal<Void>
        let errorMessage: Signal<String>
    }
    
    // MARK: - Properties
    
    private let userUseCase: UserUseCaseProtocol
    private let nicknameRelay = BehaviorRelay<String>(value: "")
    private let isDeletingRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let successRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<String> in
                guard let self else { return .just("") }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let profile = try await self.userUseCase.fetchProfile()
                            observer.onNext(profile.nickname)
                            observer.onCompleted()
                        } catch {
                            print("❌ 프로필 조회 실패: \(error.localizedDescription)")
                            observer.onNext("회원")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .bind(to: nicknameRelay)
            .disposed(by: disposeBag)
        
        input.deleteTap
            .do(onNext: { [weak self] _ in
                self?.isDeletingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<Result<Void, Error>> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.userUseCase.deleteAccount()
                            observer.onNext(.success(()))
                            observer.onCompleted()
                        } catch {
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                        }
                        self.isDeletingRelay.accept(false)
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    successRelay.accept(())
                case .failure(let error):
                    errorRelay.accept("회원 탈퇴에 실패했습니다. 잠시 후 다시 시도해주세요.")
                    print("❌ 회원 탈퇴 에러: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            nickname: nicknameRelay.asDriver(),
            isDeleting: isDeletingRelay.asDriver(),
            deleteSuccess: successRelay.asSignal(),
            errorMessage: errorRelay.asSignal()
        )
    }
}
