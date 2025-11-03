//
//  CalendarWorkListViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import OSLog

import RxRelay
import RxSwift

final class CalendarWorkListViewModel {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private var calendarWorkList: [WorkSummary]
    private let workUseCase: WorkUseCaseProtocol
    
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let deleteWorkId: Observable<Int>
    }
    
    // MARK: - Output
    struct Output {
        let calendarWorkList: Observable<[WorkSummary]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    private let calendarWorkListRelay = BehaviorRelay<[WorkSummary]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(workUseCase: WorkUseCaseProtocol, calendarWorkList: [WorkSummary]) {
        self.workUseCase = workUseCase
        self.calendarWorkList = calendarWorkList
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                owner.calendarWorkListRelay.accept(owner.calendarWorkList)
            }.disposed(by: disposeBag)
        
        input.deleteWorkId
            .subscribe(with: self) { owner, id in
                owner.fetchTask?.cancel()
                owner.fetchTask = Task {
                    defer {
                        if !Task.isCancelled { owner.calendarWorkListRelay.accept(owner.calendarWorkList) }
                    }
                    
                    do {
                        try await owner.workUseCase.deleteWork(workId: id)
                        owner.calendarWorkList = owner.calendarWorkList.filter { $0.id != id }
                    } catch is CancellationError {
                        owner.logger.info("근무 삭제 Task가 취소되었습니다.")
                    } catch let error as LocalizedError {
                        owner.errorMessageRelay.accept((title: "근무 삭제 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                    } catch {
                        owner.errorMessageRelay.accept((title: "근무 삭제 실패", message: "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(calendarWorkList: calendarWorkListRelay.asObservable(),
                      errorMessage: errorMessageRelay.asObservable())
    }
}
