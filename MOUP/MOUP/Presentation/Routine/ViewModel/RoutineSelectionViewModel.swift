//
//  RoutineSelectionViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import Foundation
import RxSwift
import RxCocoa

struct DummyRoutine {
    let name: String
    let time: String
}

final class RoutineSelectionViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let rows: Driver<[DummyRoutine]>
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let rows = input.viewDidLoad
        // TODO: - usecase 호출하여 실제 데이터 연동
            .map { _ -> [DummyRoutine] in
                return [
                    DummyRoutine(name: "오픈", time: "09 : 00"),
                    DummyRoutine(name: "폐기", time: "15 : 00"),
                    DummyRoutine(name: "마감", time: "18 : 00")
                ]
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(rows: rows)
    }
}
