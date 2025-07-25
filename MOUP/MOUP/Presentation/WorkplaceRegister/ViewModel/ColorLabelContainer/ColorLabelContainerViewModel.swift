//
//  ColorLabelContainerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import RxSwift
import RxCocoa

protocol ColorLabelContainerViewModelInput {
    var didTapColorLabel: AnyObserver<Void> { get }
}

protocol ColorLabelContainerViewModelOutput {
    var showColorLabel: Observable<Void> { get }
}

final class ColorLabelContainerViewModel: ColorLabelContainerViewModelInput, ColorLabelContainerViewModelOutput {

    // Input
    private let didTapColorLabelSubject = PublishSubject<Void>()
    
    var didTapColorLabel: AnyObserver<Void> { didTapColorLabelSubject.asObserver() }

    // Output
    var showColorLabel: Observable<Void> {
        didTapColorLabelSubject.asObservable()
    }

    init() { }
}
