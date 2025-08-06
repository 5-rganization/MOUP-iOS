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
    var selectedColorLabel: Driver<String> { get }
}

final class ColorLabelContainerViewModel: ColorLabelContainerViewModelInput, ColorLabelContainerViewModelOutput {

    // MARK: - Input
    private let didTapColorLabelSubject = PublishSubject<Void>()
    var didTapColorLabel: AnyObserver<Void> { didTapColorLabelSubject.asObserver() }

    // MARK: - Output
    let showColorLabel: Observable<Void>
    let selectedColorLabel: Driver<String>

    // MARK: - Init
    init(selectColorLabelViewModel: SelectColorLabelViewModel) {
        self.showColorLabel = didTapColorLabelSubject.asObservable()

        self.selectedColorLabel = selectColorLabelViewModel.confirmedColor
            .asDriver(onErrorJustReturn: "")
    }
}

