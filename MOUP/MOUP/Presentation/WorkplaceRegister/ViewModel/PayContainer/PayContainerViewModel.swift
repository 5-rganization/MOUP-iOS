//
//  PayContainerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 7/17/25.
//

import RxSwift
import RxCocoa

protocol PayContainerViewModelInput {
    var didTapPayType: AnyObserver<Void> { get }
    var didTapPayCalculation: AnyObserver<Void> { get }
    var didTapSalaryType: AnyObserver<Void> { get }
}

protocol PayContainerViewModelOutput {
    var showPayType: Observable<Void> { get }
    var showPayCalculation: Observable<Void> { get }
    var showSalaryType: Observable<Void> { get }
}

final class PayContainerViewModel: PayContainerViewModelInput, PayContainerViewModelOutput {

    // Input
    private let didTapPayTypeSubject = PublishSubject<Void>()
    private let didTapPayCalculationSubject = PublishSubject<Void>()
    private let didTapSalaryTypeSubject = PublishSubject<Void>()
    
    var didTapPayType: AnyObserver<Void> { didTapPayTypeSubject.asObserver() }
    var didTapPayCalculation: AnyObserver<Void> { didTapPayCalculationSubject.asObserver() }
    var didTapSalaryType: AnyObserver<Void> { didTapSalaryTypeSubject.asObserver() }

    // Output
    var showPayType: Observable<Void> {
        didTapPayTypeSubject.asObservable()
    }
    
    var showPayCalculation: Observable<Void> {
        didTapPayCalculationSubject.asObserver()
    }
    
    var showSalaryType: Observable<Void> {
        didTapSalaryTypeSubject.asObserver()
    }

    init() { }
}
