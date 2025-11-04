//
//  FilterViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/3/25.
//

import OSLog

import RxRelay
import RxSwift

/// 필터 VM
final class FilterViewModel {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<CalendarMode>
    }
    
    // MARK: - Output
    struct Output {
        let filterWorkplaceList: Observable<[WorkplaceSummary]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    private let filterWorkplaceListRelay = BehaviorRelay<[WorkplaceSummary]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workplaceUseCase = workplaceUseCase
    }
    
    // MARK: - Input ➡️ Output Transform
    @MainActor
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(with: self) { owner, calendarMode in
                owner.fetchTask?.cancel()
                owner.fetchTask = Task {
                    var filterList: [WorkplaceSummary] = []
                    defer {
                        if !Task.isCancelled {
                            filterList.sort { lhs, rhs in
                                if lhs.id == -1 { return true }
                                if rhs.id == -1 { return false }
                                return lhs.name < rhs.name
                            }
                            owner.filterWorkplaceListRelay.accept(filterList)
                        }
                    }
                    
                    do {
                        switch calendarMode {
                        case .personal:
                            filterList = try await owner.workplaceUseCase.fetchAllWorkplace()
                            filterList = [WorkplaceSummary(id: -1, name: "전체 보기", isShared: false)] + filterList
                        case .shared:
                            filterList = try await owner.workplaceUseCase.fetchSharedWorkplaceOnly()
                        }
                    } catch is CancellationError {
                        owner.logger.info("캘린더 근무지(매장) 필터 로딩 Task가 취소되었습니다.")
                    } catch let error as LocalizedError {
                        switch UserRole(rawValue: UserDefaultsManager.shared.userRole ?? UserRole.worker.rawValue)  {
                        case .worker:
                            owner.errorMessageRelay.accept((title: "근무지 목록 불러오기 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        case .owner:
                            owner.errorMessageRelay.accept((title: "매장 목록 불러오기 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        default:
                            owner.errorMessageRelay.accept((title: "근무지(매장) 목록 불러오기 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    } catch {
                        owner.errorMessageRelay.accept((title: "근무지(매장) 목록 불러오기 실패", message: "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(filterWorkplaceList: filterWorkplaceListRelay.asObservable(),
                      errorMessage: errorMessageRelay.asObservable())
    }
}
