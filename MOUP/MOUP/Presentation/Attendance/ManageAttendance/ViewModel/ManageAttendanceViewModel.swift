//
//  ManageAttendanceViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import Foundation
import RxSwift
import RxRelay

final class ManageAttendanceViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let attendanceUseCase: AttendanceUseCaseProtocol
    private lazy var employeesRelay = BehaviorRelay<[ManageAttendanceItem]>(value: [])
    
    // MARK: - Initializer
    init(attendanceUseCase: AttendanceUseCaseProtocol) {
        self.attendanceUseCase = attendanceUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let employees: Observable<[ManageAttendanceItem]>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.fetchWorkers()
            })
            .disposed(by: disposeBag)
        
        return Output(employees: employeesRelay.asObservable())
    }
    
}

private extension ManageAttendanceViewModel {
    func fetchWorkers() {
        Task {
            do {
//                try await attendanceUseCase.fetchWorkers
            }
        }
    }
}
