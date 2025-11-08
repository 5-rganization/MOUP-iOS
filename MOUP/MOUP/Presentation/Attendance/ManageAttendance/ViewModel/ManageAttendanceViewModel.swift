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
    let workplaceId: Int
    private let attendanceUseCase: AttendanceUseCaseProtocol
    private lazy var workersRelay = BehaviorRelay<[ManageAttendanceItem]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(
        attendanceUseCase: AttendanceUseCaseProtocol,
        workplaceId: Int
    ) {
        self.attendanceUseCase = attendanceUseCase
        self.workplaceId = workplaceId
    }
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let workers: Observable<[ManageAttendanceItem]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.fetchWorkers()
            })
            .disposed(by: disposeBag)
        
        return Output(
            workers: workersRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
    
}

private extension ManageAttendanceViewModel {
    func fetchWorkers() {
        Task { @MainActor in
            do {
                let response = try await attendanceUseCase.fetchWorkplaceWorkers(
                    workplaceId: self.workplaceId,
                    isActiveOnly: false // default: false
                )
                workersRelay.accept(
                    [ManageAttendanceItem(
                        items: response
                    )]
                )
            } catch is AttendanceError {
                errorMessageRelay.accept(
                    (
                        title: "근무자 불러오기 실패",
                        message: "매장 내 근무자 목록을 불러오는 데에 실패했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            } catch is NetworkError {
                errorMessageRelay.accept(
                    (
                        title: "알 수 없는 오류",
                        message: "예기치 못한 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            }
        }
    }
}
