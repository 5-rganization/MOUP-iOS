//
//  InputNameViewModel.swift
//  MOUP
//
//  Created by 양원식 on 7/28/25.
//

import RxSwift
import RxCocoa

protocol InputNameViewModelInput {
    var nameText: AnyObserver<String> { get }
}

protocol InputNameViewModelOutput {
    var isValidName: Driver<Bool> { get }
    var nameTextOutput: Driver<String> { get }
}

final class InputNameViewModel: InputNameViewModelInput, InputNameViewModelOutput {

    // MARK: Input
    private let nameTextSubject = PublishSubject<String>()
    var nameText: AnyObserver<String> { nameTextSubject.asObserver() }

    // MARK: Output
    let isValidName: Driver<Bool>
    let nameTextOutput: Driver<String>

    private let disposeBag = DisposeBag()

    init() {
        let nameTextStream = nameTextSubject
            .map { $0.trimmingCharacters(in: .whitespaces) }

        isValidName = nameTextStream
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        nameTextOutput = nameTextStream
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
}
