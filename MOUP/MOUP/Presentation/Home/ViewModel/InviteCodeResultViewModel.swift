//
//  InviteCodeResultViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 11/3/25.
//

import Foundation
import RxSwift
import RxRelay

final class InviteCodeResultViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let inviteCodeWorkplaceRelay: BehaviorRelay<InviteCodeWorkplace>
    private let inviteCode: String
    
    // MARK: - Initializer
    init(workplace: InviteCodeWorkplace, inviteCode: String) {
        self.inviteCode = inviteCode
        self.inviteCodeWorkplaceRelay = BehaviorRelay(value: workplace)
    }
    
    // MARK: - Input, Output
    struct Input {
        
    }
    
    struct Output {
        let workplace: Observable<InviteCodeWorkplace>
        let inviteCode: String
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        return Output(
            workplace: inviteCodeWorkplaceRelay.asObservable(),
            inviteCode: inviteCode
        )
    }
    
}
