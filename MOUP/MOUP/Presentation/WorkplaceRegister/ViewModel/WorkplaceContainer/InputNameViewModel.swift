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
    func confirmName()
}

protocol InputNameViewModelOutput {
    var isValidName: Driver<Bool> { get }
    var currentNameText: Driver<String> { get }
    var confirmedName: Observable<String> { get }
}

final class InputNameViewModel: InputNameViewModelInput, InputNameViewModelOutput {

    // MARK: - Input Relays
    private let nameTextRelay = BehaviorRelay<String>(value: "")
    private let confirmedNameRelay = BehaviorRelay<String>(value: "입력")
    
    // MARK: - Input
    var nameText: AnyObserver<String> {
        AnyObserver { [weak self] event in
            guard let value = event.element else { return }
            self?.nameTextRelay.accept(value)
        }
    }

    func confirmName() {
        confirmedNameRelay.accept(nameTextRelay.value)
    }

    // MARK: - Output
    var isValidName: Driver<Bool>
    var currentNameText: Driver<String>
    var confirmedName: Observable<String> {
        confirmedNameRelay.asObservable()
    }

    // MARK: - Init
    init() {
        let trimmedText = nameTextRelay
            .map { $0.trimmingCharacters(in: .whitespaces) }

        isValidName = trimmedText
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        currentNameText = trimmedText
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
}


