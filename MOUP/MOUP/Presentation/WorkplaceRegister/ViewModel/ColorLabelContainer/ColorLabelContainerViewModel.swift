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

    let selectColorLabelViewModel: SelectColorLabelViewModel
    
    private let didTapColorLabelSubject = PublishSubject<Void>()
    var didTapColorLabel: AnyObserver<Void> { didTapColorLabelSubject.asObserver() }

    let showColorLabel: Observable<Void>
    let selectedColorLabel: Driver<String>

    init(selectColorLabelViewModel: SelectColorLabelViewModel) {

        self.selectColorLabelViewModel = selectColorLabelViewModel
        self.showColorLabel = didTapColorLabelSubject.asObservable()

        self.selectedColorLabel = selectColorLabelViewModel.confirmedColor
            .asDriver(onErrorJustReturn: "")
    }
}
