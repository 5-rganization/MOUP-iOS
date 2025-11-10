//
//  HomeViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import os
import Foundation
import RxSwift
import RxRelay

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "HomeViewModel")

final class HomeViewModel {
    // MARK: - Properties
    let userRole: UserRole
    private let disposeBag = DisposeBag()
    private let homeUseCase: HomeUseCaseProtocol
    private let attendanceUseCase: AttendanceUseCaseProtocol
    private let notificationUseCase: NotificationUseCaseProtocol
    
    private let homeHeaderDataRelay = BehaviorRelay<HomeHeaderData>(
        value: HomeHeaderData(
            nowMonth: 0,
            totalSalary: 0,
            todayRoutineCounts: 0,
            prevMonthSalaryDiff: 0
        )
    )
    private let firstSectionDataRelay = BehaviorRelay<[HomeTableViewFirstSection]>(
        value: [HomeTableViewFirstSection(identity: 0, header: "", items: [])]
    )
    private let activeWorkplaceRelay = BehaviorRelay<WorkplaceMonthSummary?>(value: nil)
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    private let unreadCountRelay = BehaviorRelay<Int>(value: 0)
    
    init(
        userRole: UserRole,
        homeUseCase: HomeUseCaseProtocol,
        attendanceUseCase: AttendanceUseCaseProtocol,
        notificationUseCase: NotificationUseCaseProtocol
    ) {
        self.userRole = userRole
        self.homeUseCase = homeUseCase
        self.attendanceUseCase = attendanceUseCase
        self.notificationUseCase = notificationUseCase
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
        let didRefresh: Observable<Void>
        let startWorkTapped: Observable<Int>
        let endWorkTapped: Observable<Int>
        let viewWillAppear: Observable<Void>
    }

    struct Output {
        let firstSectionData: Observable<[HomeTableViewFirstSection]>
        let homeHeaderData: Observable<HomeHeaderData>
        let activeWorkplace: Observable<WorkplaceMonthSummary?>
        let errorMessage: Observable<(title: String, message: String)>
        let unreadCount: Observable<Int>
    }

    // MARK: - transform
    func transform(input: Input) -> Output {
        // 초기 데이터 바인딩
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.fetchHomeData()
        })
        .disposed(by: disposeBag)
        
        input.didRefresh
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.fetchHomeData() // TODO: - 로딩 애니메이션
            })
            .disposed(by: disposeBag)

        input.startWorkTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, id in
                owner.startWork(workplaceId: id)
            })
            .disposed(by: disposeBag)
        
        input.endWorkTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, id in
                owner.endWork(workplaceId: id)
            })
            .disposed(by: disposeBag)
        
        Observable.merge(input.viewDidLoad, input.viewWillAppear)
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                guard let self else { return .just(0) }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let notifications = try await self.notificationUseCase.fetchNotifications()
                            let unreadCount = notifications.filter { !$0.isRead }.count
                            observer.onNext(unreadCount)
                            observer.onCompleted()
                        } catch {
                            observer.onNext(0)
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .bind(to: unreadCountRelay)
            .disposed(by: disposeBag)
        
        return Output(
            firstSectionData: firstSectionDataRelay.asObservable(),
            homeHeaderData: homeHeaderDataRelay.asObservable(),
            activeWorkplace: activeWorkplaceRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable(),
            unreadCount: unreadCountRelay.asObservable()
        )
    }

    private func fetchHomeData() {
        switch userRole {
        case .worker:
            fetchHomeWorkerData()
        case .owner:
            fetchHomeOwnerData()
        }
    }
}

// MARK: - Network Methods
private extension HomeViewModel {
    func fetchHomeWorkerData() {
        Task {
            LoadingManager.start()
            defer { LoadingManager.stop() }
            
            do {
                let result = try await homeUseCase.fetchWorkerHomeData()
                await MainActor.run {
                    homeHeaderDataRelay.accept( // 헤더 데이터 주입
                        HomeHeaderData(
                            nowMonth: result.month,
                            totalSalary: result.totalSalary,
                            todayRoutineCounts: result.todayRoutineCount,
                            prevMonthSalaryDiff: result.prevMonthSalaryDiff
                        )
                    )
                    firstSectionDataRelay.accept(
                        [
                            HomeTableViewFirstSection.init(
                                identity: 0,
                                header: "",
                                items: result.workplaces.map({ workplace in
                                    return HomeSectionItem.worker(workplace)
                                })
                            )
                        ]
                    )
                    // 출근 중인 근무지 찾기
                    let activeWorkplace = result.workplaces.first {
                        $0.homeWorkplace.isNowWorking == true
                    }
                    activeWorkplaceRelay.accept(activeWorkplace)
                    
                }
            } catch {
                // TODO: - 잘못된 역할 등 예상치 못한 오류 발생 시 대책 강구 필요
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func fetchHomeOwnerData() {
        Task {
            LoadingManager.start()
            defer { LoadingManager.stop() }
            
            do {
                let result = try await homeUseCase.fetchOwnerHomeData()
                await MainActor.run {
                    homeHeaderDataRelay.accept(
                        HomeHeaderData(
                            nowMonth: result.month,
                            totalSalary: result.totalSalary,
                            todayRoutineCounts: result.todayRoutineCount,
                            prevMonthSalaryDiff: result.prevMonthSalaryDiff
                        )
                    )
                    firstSectionDataRelay.accept(
                        [
                            HomeTableViewFirstSection.init(
                                identity: 0,
                                header: "",
                                items: result.workplaces.map({ workplace in
                                    return HomeSectionItem.owner(workplace)
                                })
                            )
                        ]
                    )
                }
            } catch {
                // TODO: - 잘못된 역할 등 예상치 못한 오류 발생 시 대책 강구 필요
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func startWork(workplaceId: Int) {
        Task { 
            do {
                try await attendanceUseCase.startWork(workplaceId: workplaceId)
                await handleAttendanceSuccess()
            } catch let error as NetworkError {
                switch error {
                case .serverError:
                    errorMessageRelay.accept(
                        (
                            title: "서버 오류",
                            message: "현재 서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                        )
                    )
                default:
                    errorMessageRelay.accept(
                        (
                            title: "알 수 없는 오류",
                            message: "예기치 못한 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                        )
                    )
                }
            } catch is AttendanceError {
                errorMessageRelay.accept(
                    (
                        title: "출근 처리 실패",
                        message: "출근 처리에 실패했습니다.\n잠시 후 다시 시도해주세요."
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
    
    func endWork(workplaceId: Int) {
        Task {
            do {
                try await attendanceUseCase.endWork(workplaceId: workplaceId)
                await handleAttendanceSuccess()
            } catch let error as NetworkError {
                switch error {
                case .serverError:
                    errorMessageRelay.accept(
                        (
                            title: "서버 오류",
                            message: "현재 서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                        )
                    )
                default:
                    errorMessageRelay.accept(
                        (
                            title: "알 수 없는 오류",
                            message: "예기치 못한 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
                        )
                    )
                }
            } catch is AttendanceError {
                errorMessageRelay.accept(
                    (
                        title: "퇴근 처리 실패",
                        message: "퇴근 처리에 실패했습니다.\n잠시 후 다시 시도해주세요."
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
    
    func handleAttendanceSuccess() async {
        await MainActor.run { fetchHomeData() }
    }
}
