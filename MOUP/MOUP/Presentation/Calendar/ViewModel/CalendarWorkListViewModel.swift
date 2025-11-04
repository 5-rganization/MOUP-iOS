//
//  CalendarWorkListViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import OSLog

import RxRelay
import RxSwift

/// 캘린더 근무 목록 VM
final class CalendarWorkListViewModel {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private let workUseCase: WorkUseCaseProtocol
    private let calendarWorkList: Observable<[WorkSummary]>
    
    // MARK: - Input
    struct Input {
        let deleteSingleWorkId: Observable<Int>
        let deleteRecurringWorkId: Observable<Int>
    }
    
    // MARK: - Output
    struct Output {
        let calendarWorkList: Observable<[WorkSummary]>
        let errorMessage: Observable<(title: String, message: String)>
        let updateCalendar: Observable<Void>
    }
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    private let updateCalendarRelay = PublishRelay<Void>()
    
    // MARK: - Initializer
    init(workUseCase: WorkUseCaseProtocol, calendarWorkList: Observable<[WorkSummary]>) {
        self.workUseCase = workUseCase
        self.calendarWorkList = calendarWorkList
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        input.deleteSingleWorkId
            .subscribe(with: self) { owner, workId in
                Task.detached {
                    do {
                        try await owner.workUseCase.deleteWork(workId: workId)
                        await MainActor.run { owner.updateCalendarRelay.accept(()) }
                    } catch let error as LocalizedError {
                        await MainActor.run {
                            owner.errorMessageRelay.accept((title: "근무 삭제 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    } catch {
                        await MainActor.run {
                            owner.errorMessageRelay.accept((title: "근무 삭제 실패", message: "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    }
                }
            }.disposed(by: disposeBag)
        
        input.deleteRecurringWorkId
            .subscribe(with: self) { owner, workId in
                Task.detached {
                    do {
                        try await owner.workUseCase.deleteRecurringWork(workId: workId)
                        await MainActor.run { owner.updateCalendarRelay.accept(()) }
                    } catch let error as LocalizedError {
                        await MainActor.run {
                            owner.errorMessageRelay.accept((title: "근무 삭제 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    } catch {
                        await MainActor.run {
                            owner.errorMessageRelay.accept((title: "근무 삭제 실패", message: "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(calendarWorkList: calendarWorkList,
                      errorMessage: errorMessageRelay.asObservable(),
                      updateCalendar: updateCalendarRelay.asObservable())
    }
}
