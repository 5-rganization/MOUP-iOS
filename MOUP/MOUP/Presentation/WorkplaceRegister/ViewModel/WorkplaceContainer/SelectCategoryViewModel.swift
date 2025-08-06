//
//  SelectCategoryViewModel.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//
import RxSwift
import RxCocoa

protocol SelectCategoryViewModelInput {
    var didSelectCategory: AnyObserver<String> { get }
    var didTapConfirm: AnyObserver<Void> { get }
}

protocol SelectCategoryViewModelOutput {
    var isCategorySelected: Driver<Bool> { get }
    var confirmedCategory: Observable<String> { get }
    var selectedCategory: Observable<String?> { get }
}

final class SelectCategoryViewModel: SelectCategoryViewModelInput, SelectCategoryViewModelOutput {

    // MARK: - Properties
    private let didSelectCategorySubject = PublishSubject<String>()
    private let didTapConfirmSubject = PublishSubject<Void>()

    private let selectedCategoryRelay = BehaviorRelay<String?>(value: nil)
    private let confirmedCategorySubject = BehaviorRelay<String?>(value: nil)

    // Input
    var didSelectCategory: AnyObserver<String> { didSelectCategorySubject.asObserver() }
    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }

    // Output
    var selectedCategory: Observable<String?> { selectedCategoryRelay.asObservable() }
    var confirmedCategory: Observable<String> {
        confirmedCategorySubject
            .compactMap { $0 } // nil 제거
            .asObservable()
    }
    var isCategorySelected: Driver<Bool> {
        selectedCategoryRelay
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
    }

    private let disposeBag = DisposeBag()

    init() {
        bind()
    }

    private func bind() {
        // 사용자가 버튼 클릭 시 선택 값 반영
        didSelectCategorySubject
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)

        // 완료 버튼 탭 시 확정
        didTapConfirmSubject
            .withLatestFrom(selectedCategoryRelay)
            .bind(to: confirmedCategorySubject)
            .disposed(by: disposeBag)
    }

    func resetToConfirmedCategoryIfNeeded() {
        selectedCategoryRelay.accept(confirmedCategorySubject.value)
    }
    
    func resetSelectedCategory() {
        selectedCategoryRelay.accept(nil)
    }

}






