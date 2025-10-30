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
    private let userRole: UserRole
    private let disposeBag = DisposeBag()
    private let homeUseCase: HomeUseCaseProtocol
    
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
    ) // TODO: - nil을 허용할지 실제 백엔드 데이터 및 구조 확립 후 개선 필요
    
    init(userRole: UserRole, useCase: HomeUseCaseProtocol) {
        self.userRole = userRole
        self.homeUseCase = useCase
    }

    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }

    struct Output {
        let firstSectionData: Observable<[HomeTableViewFirstSection]>
        let homeHeaderData: Observable<HomeHeaderData>
    }

    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad.subscribe(onNext: { [weak self] in
            guard let self else { return }
            switch userRole {
            case .worker:
                fetchHomeWorkerData()
            case .owner:
                fetchHomeOwnerData()
            }
        })
        .disposed(by: disposeBag)

        return Output(
            firstSectionData: firstSectionDataRelay.asObservable(),
            homeHeaderData: homeHeaderDataRelay.asObservable()
        )
    }

}

private extension HomeViewModel {
    func fetchHomeWorkerData() {
        Task {
            do {
                let result = try await homeUseCase.fetchWorkerHomeData()
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
            } catch {
                // TODO: - 잘못된 역할 등 예상치 못한 오류 발생 시 대책 강구 필요
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func fetchHomeOwnerData() {
        Task {
            do {
                let result = try await homeUseCase.fetchOwnerHomeData()
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
            } catch {
                // TODO: - 잘못된 역할 등 예상치 못한 오류 발생 시 대책 강구 필요
                logger.error("\(error.localizedDescription)")
            }
        }
    }
}
