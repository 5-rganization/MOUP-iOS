//
//  InviteCodeInputViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation
import RxSwift
import RxRelay

final class InviteCodeInputViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let searchResultRelay = BehaviorRelay<Void>(value: ())
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    // MARK: - Initializer
    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let searchBtnTapped: Observable<String>
    }
    
    struct Output {
        let searchResult: Observable<Void> // TODO: - 실제 조회 후 결과 타입으로 정의 필요
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.searchBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, inviteCode in
                print(inviteCode)
            })
            .disposed(by: disposeBag)
        
        return Output(searchResult: searchResultRelay.asObservable())
    }
}
