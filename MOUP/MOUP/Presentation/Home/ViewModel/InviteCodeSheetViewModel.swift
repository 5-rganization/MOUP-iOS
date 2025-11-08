//
//  InviteCodeSheetViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 9/29/25.
//

import Foundation
import RxSwift
import RxRelay

final class InviteCodeSheetViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let inviteCodeRelay = BehaviorRelay<String>(value: "")
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let workplaceId: Observable<Int>
    }
    
    struct Output {
        let inviteCode: Observable<String>
        let errorMessage: Observable<(title: String, message: String)>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.workplaceId
            .withUnretained(self)
            .subscribe(onNext: { owner, id in
                owner.fetchInviteCode(workplaceId: id)
            })
            .disposed(by: disposeBag)
        
        return Output(
            inviteCode: inviteCodeRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
}

private extension InviteCodeSheetViewModel {
    func fetchInviteCode(workplaceId: Int) {
        Task {
            await MainActor.run { LoadingManager.start() }
            defer { Task { @MainActor in LoadingManager.stop() } }
            
            do {
                let response = try await workplaceUseCase.fetchInviteCode(workplaceId: workplaceId, forceGenerate: false)
                inviteCodeRelay.accept(response.inviteCode)
            } catch {
                errorMessageRelay.accept((title: "알 수 없는 오류가 발생했어요.", message: "초대 코드를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요."))
            }
        }
    }
    
}

