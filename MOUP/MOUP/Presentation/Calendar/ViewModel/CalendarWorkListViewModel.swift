//
//  CalendarWorkListViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import RxRelay
import RxSwift

final class CalendarWorkListViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private var calendarWorkList: [CalendarWork] = []
    
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let deleteWorkId: Observable<Int64>
    }
    
    // MARK: - Output
    struct Output {
        let calendarWorkList: Observable<[CalendarWork]>
    }
    private let calendarWorkListRelay = BehaviorRelay<[CalendarWork]>(value: [])
    
    // MARK: - Initializer
    init(calendarWorkList: [CalendarWork]) {
        self.calendarWorkList = calendarWorkList
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                owner.calendarWorkListRelay.accept(owner.calendarWorkList)
            }.disposed(by: disposeBag)
        
        input.deleteWorkId
            .subscribe(with: self) { owner, id in
                // TODO: 근무 삭제 API 호출
                // 삭제 확인된 경우
                owner.calendarWorkList = owner.calendarWorkList.filter { $0.id != id }
                owner.calendarWorkListRelay.accept(owner.calendarWorkList)
            }.disposed(by: disposeBag)
        
        return Output(calendarWorkList: calendarWorkListRelay.asObservable())
    }
}
