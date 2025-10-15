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
    private let inviteCodeRelay = BehaviorRelay<String>(value: "XC1234")
    
    // MARK: - Input, Output
    struct Input {
        
    }
    
    struct Output {
        let inviteCode: Observable<String>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        return Output(
            inviteCode: inviteCodeRelay.asObservable()
        )
    }
}
