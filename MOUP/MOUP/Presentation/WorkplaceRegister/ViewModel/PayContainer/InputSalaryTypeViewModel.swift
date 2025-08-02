//
//  InputSalaryTypeViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/2/25.
//

import RxSwift
import RxCocoa

protocol InputSalaryTypeViewModelOutput {
    var salaryTypeTitleOutput: Driver<String> { get }
    var placeholderText: Driver<String> { get }
}

final class InputSalaryTypeViewModel: InputSalaryTypeViewModelOutput {
    
    // Output
    let salaryTypeTitleOutput: Driver<String>
    let placeholderText: Driver<String>

    init(confirmedPayCalculation: Observable<String>) {
        self.salaryTypeTitleOutput = confirmedPayCalculation
            .map { type in
                type == "시급" ? "시급을 입력해주세요." : "고정급을 입력해주세요."
            }
            .asDriver(onErrorJustReturn: "급여를 먼저 입력해주세요.")
        
        self.placeholderText = confirmedPayCalculation
            .map { $0 == "시급" ? "\(MinimumWage.hourly)" : "\(MinimumWage.monthly)" }
            .asDriver(onErrorJustReturn: "")
    }
}
