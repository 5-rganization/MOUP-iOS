//
//  WorkRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/11/25.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

// MARK: - Input / Output
protocol WorkRegisterViewModelInput {
    var didTapRegister: PublishRelay<Void> { get }
    var memoText: BehaviorRelay<String> { get }
}

protocol WorkRegisterViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRegister: PublishRelay<Void> { get }
}

// MARK: - ViewModel
final class WorkRegisterViewModel:
    WorkRegisterViewModelInput,
    WorkRegisterViewModelOutput {

    // MARK: - Sub ViewModels
    let selectedWorkplaceVM: SelectedWorkplaceViewModel
    let datePickerVM: WorkDatePickerViewModel
    let clockInVM: WorkTimePickerViewModel
    let clockOutVM: WorkTimePickerViewModel
    let breakPickerVM: WorkBreakPickerViewModel

    // MARK: - Input
    let didTapRegister = PublishRelay<Void>()
    let memoText = BehaviorRelay<String>(value: "")

    // MARK: - Output
    let isFormValid: Driver<Bool>
    let didCompleteRegister = PublishRelay<Void>()

    // MARK: - Dependencies
    private let workUseCase: WorkUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        selectedWorkplaceVM: SelectedWorkplaceViewModel,
        datePickerVM: WorkDatePickerViewModel,
        clockInVM: WorkTimePickerViewModel,
        clockOutVM: WorkTimePickerViewModel,
        breakPickerVM: WorkBreakPickerViewModel,
        workUseCase: WorkUseCaseProtocol
    ) {
        self.selectedWorkplaceVM = selectedWorkplaceVM
        self.datePickerVM = datePickerVM
        self.clockInVM = clockInVM
        self.clockOutVM = clockOutVM
        self.breakPickerVM = breakPickerVM
        self.workUseCase = workUseCase

        // MARK: - Validation
        let workplaceSelected = selectedWorkplaceVM.confirmSelectedWorkplace
            .map { _ in true }
            .startWith(false)

        let dateSelected = datePickerVM.confirmSelectedDate
            .map { _ in true }
            .startWith(false)

        let clockInSelected = clockInVM.confirmSelectedTime
            .map { _ in true }
            .startWith(false)

        let clockOutSelected = clockOutVM.confirmSelectedTime
            .map { _ in true }
            .startWith(false)

        self.isFormValid = Observable
            .combineLatest(workplaceSelected, dateSelected, clockInSelected, clockOutSelected)
            .map { $0 && $1 && $2 && $3 }
            .asDriver(onErrorJustReturn: false)

        // MARK: - Register Action
        didTapRegister
            .withLatestFrom(
                Observable.combineLatest(
                    selectedWorkplaceVM.confirmSelectedWorkplace,
                    datePickerVM.confirmSelectedDate,
                    clockInVM.confirmSelectedTime,
                    clockOutVM.confirmSelectedTime,
                    breakPickerVM.confirmSelectedBreak.startWith(0),
                    memoText.asObservable()
                )
            )
            .subscribe(onNext: { [weak self] (workplace, date, clockIn, clockOut, breakMinutes, memo) in
                let dateStr = DateFormatter.dataSourceDateFormatter.string(from: date)
                let clockInStr = DateFormatter.ko12hTimeFormatter.string(from: clockIn)
                let clockOutStr = DateFormatter.ko12hTimeFormatter.string(from: clockOut)

                print("""
                근무 등록 요청 ---------------------------------
                근무지 ID: \(workplace.id)
                근무지 이름: \(workplace.name)
                근무 날짜: \(dateStr)
                출근 시간: \(clockInStr)
                퇴근 시간: \(clockOutStr)
                휴게 시간: \(breakMinutes)분
                메모: \(memo)
                --------------------------------------------------
                """)

                self?.didCompleteRegister.accept(())
            })
            .disposed(by: disposeBag)
    }
}
