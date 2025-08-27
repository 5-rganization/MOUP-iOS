//
//  FilterViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/3/25.
//

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
        let filterWorkplaceList: Observable<[FilterWorkplace]>
    }
    private let filterWorkplaceListRelay = BehaviorRelay<[FilterWorkplace]>(value: [])
    
    // MARK: - Initializer
    init() {
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(with: self) { owner, calendarMode in
                // TODO: 사용자의 근무지/매장 불러오기
                let filterList: [FilterWorkplace]
                switch calendarMode {
                case .personal:
                    filterList = [FilterWorkplace(workplaceId: -1, workplaceName: "전체 보기", isShared: false)] + CalendarMockData.filterListMock.sorted(by: { $0.workplaceName < $1.workplaceName })
                case .shared:
                    filterList = CalendarMockData.filterListMock.filter({ $0.isShared == true }).sorted(by: { $0.workplaceName < $1.workplaceName })
                }
                owner.filterWorkplaceListRelay.accept(filterList)
            }.disposed(by: disposeBag)
        
        return Output(filterWorkplaceList: filterWorkplaceListRelay.asObservable())
    }
}
