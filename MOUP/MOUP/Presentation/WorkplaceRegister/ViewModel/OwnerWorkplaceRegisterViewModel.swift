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

enum OwnerWorkplaceMode {
    case create                      // 신규 생성
    case edit(workplaceId: Int)      // 수정 모드
}

/*
 
 수정모드 예시
 
 let vm = OwnerWorkplaceRegisterViewModel(
     mode: .edit(workplaceId: workplace.id),
     workplaceVM: WorkplaceContainerViewModel(),
     colorLabelVM: ColorLabelContainerViewModel(),
     workplaceUseCase: workplaceUseCase
 )
 
 */

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

    // MARK: - Mode
    let mode: OwnerWorkplaceMode

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
        mode: OwnerWorkplaceMode,
        workplaceVM: WorkplaceContainerViewModel,
        colorLabelVM: ColorLabelContainerViewModel,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.mode = mode
        self.workplaceVM = workplaceVM
        self.colorLabelVM = colorLabelVM
        self.workplaceUseCase = workplaceUseCase

        // MARK: - TODO: 수정모드에서 초기값 설정
        if case let .edit(workplaceId) = mode {
            print("[TODO] 수정모드 - workplaceId: \(workplaceId) 데이터 fetch 후 UI 세팅 필요")
            // 추후:
            // workplaceVM.nameTextInput.accept(fetched.name)
            // workplaceVM.categoryTextInput.accept(fetched.category)
            // colorLabelVM.selectedColorLabel.accept(fetched.color)
        }

        // MARK: - Validation Combine
        let combinedInputs = Observable
            .combineLatest(
                workplaceVM.nameTextOutput.asObservable(),
                workplaceVM.categoryTextOutput.asObservable(),
                colorLabelVM.selectedColorLabel.asObservable()
            )
            .share(replay: 1)

        self.isFormValid = combinedInputs
            .map { name, category, color in
                return !name.isEmpty && !category.isEmpty && !color.isEmpty
            }
            .asDriver(onErrorJustReturn: false)

        // MARK: - Create / Edit 공통 처리
        didTapCompleteButton
            .withLatestFrom(combinedInputs)
            .flatMapLatest { [weak self] (name, category, color) -> Observable<Int> in
                guard let self else { return .empty() }

                let mappedColor = LabelColor(displayStr: color)?.serverStr ?? LabelColor._default.serverStr

                switch self.mode {

                case .create:
                    // 신규 생성
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

                case .edit(let workplaceId):
                    print("[TODO] 수정 API 연결 필요 - workplaceId: \(workplaceId)")
                    // TODO - update API 호출
                    return Observable.just(workplaceId)
                }
            }
            .bind(to: didCompleteRegister)
            .disposed(by: disposeBag)
    }
}
