//
//  FilterViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/3/25.
//

import Foundation

import RxRelay
import RxSwift

/// 필터 VM
final class FilterViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<CalendarMode>
    }
    
    // MARK: - Output
    struct Output {
        let filterDataList: Observable<[FilterData]>
    }
    private let filterListRelay = BehaviorRelay<[FilterData]>(value: [])
    
    // MARK: - Initializer
    init() {
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(with: self) { owner, calendarMode in
                // 사용자의 근무지/매장 불러오기
                owner.filterListRelay.accept(CalendarMockData.filterListMock)
            }.disposed(by: disposeBag)
        
        return Output(filterDataList: filterListRelay.asObservable())
    }
}
