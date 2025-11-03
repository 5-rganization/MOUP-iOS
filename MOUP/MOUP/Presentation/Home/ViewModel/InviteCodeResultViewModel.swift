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
    
    // MARK: - Initializer
    init(workplace: InviteCodeWorkplace) {
        self.inviteCodeWorkplaceRelay = BehaviorRelay(value: workplace)
    }
    
    // MARK: - Input, Output
    struct Input {
        
    }
    
    struct Output {
        let workplace: Observable<InviteCodeWorkplace>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        return Output(workplace: inviteCodeWorkplaceRelay.asObservable())
    }
    
}
