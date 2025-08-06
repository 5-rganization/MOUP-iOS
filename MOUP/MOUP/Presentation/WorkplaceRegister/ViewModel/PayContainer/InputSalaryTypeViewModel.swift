//
//  InputSalaryTypeViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/2/25.
//

import RxSwift
import RxCocoa
import Foundation

protocol InputSalaryTypeViewModelInput {
    var salaryText: AnyObserver<String> { get }
    func confirmSalary()
}

protocol InputSalaryTypeViewModelOutput {
    var isValidSalary: Driver<Bool> { get }
    var confirmedSalary: Observable<String> { get }
    var salaryTypeTitleOutput: Driver<String> { get }
    var placeholderText: Driver<String> { get }
    var salaryTextOutput: Driver<String> { get }
}

final class InputSalaryTypeViewModel: InputSalaryTypeViewModelInput, InputSalaryTypeViewModelOutput {

    // MARK: - Input
    private let salaryTextRelay = BehaviorRelay<String>(value: "")
    private let confirmedSalaryRelay = BehaviorRelay<String>(value: "")

    var salaryText: AnyObserver<String> {
        AnyObserver { [weak self] event in
            guard let value = event.element else { return }
            self?.salaryTextRelay.accept(value)
        }
    }
    
    var salaryTextOutput: Driver<String> {
        salaryTextRelay.asDriver(onErrorJustReturn: "")
    }

    func confirmSalary() {
        let raw = salaryTextRelay.value.replacingOccurrences(of: ",", with: "") // 숫자만 추출
        let formattedWithoutWon = NumberFormatter.formattedDecimal(from: raw) // 예: "123,456"
        let formattedWithWon = "\(formattedWithoutWon)원" // 예: "123,456원"

        // 입력값 저장: 쉼표만 적용
        salaryTextRelay.accept(formattedWithoutWon)

        // 완료값 저장: 쉼표 + 원
        confirmedSalaryRelay.accept(formattedWithWon)
    }
    
    func currentFormattedSalaryText() -> String {
        return salaryTextRelay.value
    }


    // MARK: - Output
    let salaryTypeTitleOutput: Driver<String>
    let placeholderText: Driver<String>
    var isValidSalary: Driver<Bool>
    
    var confirmedSalary: Observable<String> {
        confirmedSalaryRelay.asObservable()
    }

    init(confirmedPayCalculation: Observable<String>) {
        salaryTypeTitleOutput = confirmedPayCalculation
            .map { $0 == "시급" ? "시급을 입력해주세요." : "고정급을 입력해주세요." }
            .asDriver(onErrorJustReturn: "")

        placeholderText = confirmedPayCalculation
            .map { $0 == "시급" ? "\(MinimumWage.hourly)" : "\(MinimumWage.monthly)" }
            .asDriver(onErrorJustReturn: "")

        isValidSalary = salaryTextRelay
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }
}
