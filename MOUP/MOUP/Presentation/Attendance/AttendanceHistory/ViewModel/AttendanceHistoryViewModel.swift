//
//  ManageAttendanceViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 9/24/25.
//

import Foundation
import RxSwift
import RxRelay

final class AttendanceHistoryViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let userRole: UserRole
    private let attendanceUseCase: AttendanceUseCaseProtocol
    private let workerId: Int? // owner일 경우에만 필요
    private let workplaceId: Int
    
    private lazy var attendanceDataRelay = BehaviorRelay<[AttendanceItem]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(
        userRole: UserRole,
        workplaceId: Int,
        workerId: Int? = nil,
        attendanceUseCase: AttendanceUseCaseProtocol
    ) {
        self.userRole = userRole
        self.workplaceId = workplaceId
        self.workerId = workerId
        self.attendanceUseCase = attendanceUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let attendanceData: Observable<[AttendanceItem]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                switch owner.userRole {
                case .worker:
                    owner.fetchWorkerWorkplaceAttendanceHistory()
                case .owner:
                    owner.fetchOwnerWorkplaceAttendanceHistory()
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            attendanceData: attendanceDataRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
        
}

private extension AttendanceHistoryViewModel {
    func fetchWorkerWorkplaceAttendanceHistory() {
        Task { @MainActor in
            do {
                let response = try await attendanceUseCase.fetchWorkerWorkplaceAttendanceHistory(workplaceId: workplaceId)
                attendanceDataRelay.accept(
                    [AttendanceItem(
                        items: response.myWorkAttendanceInfoList
                    )]
                )
            } catch is AttendanceError {
                errorMessageRelay.accept(
                    (
                        title: "근무 내역 불러오기 실패",
                        message: "근무 내역을 불러오는 데에 실패했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            } catch is NetworkError {
                errorMessageRelay.accept(
                    (
                        title: "서버 오류",
                        message: "서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            } catch {
                errorMessageRelay.accept(
                    (
                        title: "알 수 없는 오류",
                        message: "예기치 못한 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            }
        }
    }
    
    func fetchOwnerWorkplaceAttendanceHistory() {
        Task { @MainActor in
            do {
                guard let workerId else { return }
                let response = try await attendanceUseCase.fetchOwnerWorkplaceAttendanceHistory(workplaceId: workplaceId, workerId: workerId)
                attendanceDataRelay.accept(
                    [AttendanceItem(
                        items: response.workerWorkAttendanceInfoList
                    )]
                )
            } catch is AttendanceError {
                errorMessageRelay.accept(
                    (
                        title: "근무 내역 불러오기 실패",
                        message: "근무 내역을 불러오는 데에 실패했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            } catch is NetworkError {
                errorMessageRelay.accept(
                    (
                        title: "서버 오류",
                        message: "서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                    )
                )
            } catch {
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
