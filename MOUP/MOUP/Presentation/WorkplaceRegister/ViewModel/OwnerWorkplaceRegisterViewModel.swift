//
//  OwnerWorkplaceRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

// MARK: - Input / Output
protocol OwnerWorkplaceRegisterViewModelInput {
    var didTapCompleteButton: PublishRelay<Void> { get }
}

protocol OwnerWorkplaceRegisterViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRegister: PublishRelay<Int> { get }
}

final class OwnerWorkplaceRegisterViewModel:
    OwnerWorkplaceRegisterViewModelInput,
    OwnerWorkplaceRegisterViewModelOutput {

    // MARK: - Sub ViewModels
    let workplaceVM: WorkplaceContainerViewModel
    let colorLabelVM: ColorLabelContainerViewModel

    // MARK: - Input
    let didTapCompleteButton = PublishRelay<Void>()

    // MARK: - Output
    let isFormValid: Driver<Bool>
    let didCompleteRegister = PublishRelay<Int>()

    // MARK: - Dependencies
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        workplaceVM: WorkplaceContainerViewModel,
        colorLabelVM: ColorLabelContainerViewModel,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.workplaceVM = workplaceVM
        self.colorLabelVM = colorLabelVM
        self.workplaceUseCase = workplaceUseCase

        // MARK: - Combine Owner Inputs
        let combinedInputs = Observable
            .combineLatest(
                workplaceVM.nameTextOutput.asObservable(),
                workplaceVM.categoryTextOutput.asObservable(),
                colorLabelVM.selectedColorLabel.asObservable()
            )
            .share(replay: 1)

        // MARK: - Validation
        self.isFormValid = combinedInputs
            .map { name, category, color in
                return !name.isEmpty &&
                !category.isEmpty &&
                !color.isEmpty
            }
            .asDriver(onErrorJustReturn: false)

        // MARK: - Register Action
        didTapCompleteButton
            .withLatestFrom(combinedInputs)
            .flatMapLatest { [weak self] (name, category, color) -> Observable<Int> in
                guard let self else { return .empty() }

                let mappedColor = LabelColorString(displayStr: color).rawValue

                let requestDTO = OwnerWorkplaceCreateRequestDTO(
                    workplaceName: name,
                    categoryName: category,
                    ownerBasedLabelColor: mappedColor
                )

                return Observable.create { observer in
                    Task {
                        do {
                            let result = try await self.workplaceUseCase.createOwnerWorkplace(request: requestDTO)
                            observer.onNext(result.workplaceId)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .bind(to: didCompleteRegister)
            .disposed(by: disposeBag)
    }
}
