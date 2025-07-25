//
//  WorkplaceContainerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//

import RxSwift
import RxCocoa

protocol WorkplaceContainerViewModelInput {
    var didTapCategory: AnyObserver<Void> { get }
    var didTapName: AnyObserver<Void> { get }
}

protocol WorkplaceContainerViewModelOutput {
    var showCategory: Observable<Void> { get }
    var showName: Observable<Void> { get }
}

final class WorkplaceContainerViewModel: WorkplaceContainerViewModelInput, WorkplaceContainerViewModelOutput {

    // Input
    private let didTapCategorySubject = PublishSubject<Void>()
    private let didTapNameSubject = PublishSubject<Void>()
    
    var didTapCategory: AnyObserver<Void> { didTapCategorySubject.asObserver() }
    var didTapName: AnyObserver<Void> { didTapNameSubject.asObserver() }

    // Output
    var showCategory: Observable<Void> {
        didTapCategorySubject.asObservable()
    }
    
    var showName: Observable<Void> {
        didTapNameSubject.asObserver()
    }

    init() { }
}
