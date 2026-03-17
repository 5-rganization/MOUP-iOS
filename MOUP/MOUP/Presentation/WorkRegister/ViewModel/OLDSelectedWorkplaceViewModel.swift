//
//  OLDSelectedWorkplaceViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/10/25.
//

import Foundation
import RxSwift
import RxRelay

// MARK: - Input / Output
protocol OLDSelectedWorkplaceViewModelInput {
    var fetchTrigger: PublishRelay<Void> { get }
    var selectedWorkplace: PublishRelay<(id: Int, name: String)> { get }
    var didTapConfirm: PublishRelay<Void> { get }
    var didTapCancel: PublishRelay<Void> { get }
}

protocol OLDSelectedWorkplaceViewModelOutput {
    var workplaces: BehaviorRelay<[WorkplaceSummary]> { get }
    var confirmSelectedWorkplace: PublishRelay<(id: Int, name: String)> { get }
    
}

// MARK: - ViewModel
final class OLDSelectedWorkplaceViewModel:
    OLDSelectedWorkplaceViewModelInput,
    OLDSelectedWorkplaceViewModelOutput {
    
    // MARK: - Input
    let fetchTrigger = PublishRelay<Void>()
    let selectedWorkplace = PublishRelay<(id: Int, name: String)>()
    let didTapConfirm = PublishRelay<Void>()
    let didTapCancel = PublishRelay<Void>()
    
    // MARK: - Output
    let workplaces = BehaviorRelay<[WorkplaceSummary]>(value: [])
    let confirmSelectedWorkplace = PublishRelay<(id: Int, name: String)>()
    
    // MARK: - Dependencies
    private let useCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Local State
    private var currentSelected: (id: Int, name: String)?
    
    // MARK: - Init
    init(useCase: WorkplaceUseCaseProtocol) {
        self.useCase = useCase
        bind()
    }
}

// MARK: - Bind
private extension OLDSelectedWorkplaceViewModel {
    func bind() {
        // MARK: 근무지 목록 조회
        fetchTrigger
            .flatMapLatest { [weak self] _ -> Observable<[WorkplaceSummary]> in
                guard let self = self else { return .just([]) }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let list = try await self.useCase.fetchAllWorkplace()
                            observer.onNext(list)
                        } catch {
                            print("근무지 조회 실패:", error)
                            observer.onNext([])
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .bind(to: workplaces)
            .disposed(by: disposeBag)
        
        // MARK: 근무지 선택 시 현재 선택값 저장
        selectedWorkplace
            .subscribe(onNext: { [weak self] workplace in
                self?.currentSelected = workplace
            })
            .disposed(by: disposeBag)
        
        // MARK: 완료 버튼 탭 → 현재 선택 전달
        didTapConfirm
            .compactMap { [weak self] in self?.currentSelected }
            .bind(to: confirmSelectedWorkplace)
            .disposed(by: disposeBag)
    }
}
extension OLDSelectedWorkplaceViewModel {
    func applyInitial(workplaceId: Int, name: String) {
        confirmSelectedWorkplace.accept((id: workplaceId, name: name))
    }
}
