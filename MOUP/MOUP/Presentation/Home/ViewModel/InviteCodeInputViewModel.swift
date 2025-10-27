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
    private let searchResultRelay = BehaviorRelay<InviteCodeWorkplace?>(value: nil)
    private let errorMessageRelay = PublishRelay<(String, String)>()
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
        let searchResult: Observable<InviteCodeWorkplace?> // TODO: - 실제 조회 후 결과 타입으로 정의 필요
        let errorMessage: Observable<(String, String)> // (에러 타이틀, 코멘트)
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.searchBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, inviteCode in
                Task {
                    do {
                        let result = try await owner.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
                        owner.searchResultRelay.accept(result)
                    } catch let error as WorkplaceError {
                        let errorTitle: String
                        let errorMessage: String
                        switch error {
                        case .notFound:
                            errorTitle = "초대 코드를 다시 확인해 주세요."
                        case .alreadyExists:
                            errorTitle = "이미 등록된 근무지입니다." // TODO: - 에러 별 title, message 재확인 필요
                        case .invalidRole:
                            errorTitle = "유효하지 않은 접근입니다."
                        }
                        errorMessage = error.localizedDescription.description
                        owner.errorMessageRelay.accept((errorTitle, errorMessage))
                    } catch {
                        owner.errorMessageRelay.accept((
                            "예상치 못한 오류",
                            "예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                        ))
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            searchResult: searchResultRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
}

private extension InviteCodeInputViewModel {
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace {
        try await workplaceUseCase.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
}
