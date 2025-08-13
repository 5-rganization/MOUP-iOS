//
//  HomeViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import RxSwift
import RxRelay

final class HomeViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let mockFirstSectionDataRelay = BehaviorRelay<[HomeTableViewFirstSection]>(
        value: [HomeTableViewFirstSection(identity: 0, header: "", items: [])]
    ) // TODO: - nil을 허용할지 실제 백엔드 데이터 및 구조 확립 후 개선 필요

    private let mockFirstSectionData = [HomeTableViewFirstSection(identity: 0, header: "", items: [
        HomeSectionItem.worker(WorkerWorkplaceCellInfo(workplace: WorkplaceData(id: "0", name: "세븐일레븐 성남시청점", category: "편의점", payType: "매월", payCalculation: "시급", salary: "10300", payDay: "3", nationalPension: true, healthInsurance: true, employmentInsurance: true, industrialAccidentInsurance: true, incomeTax: false, weeklyHolidayAllowance: true, nightShiftAllowance: true, colorLabel: "빨간색"))),
        HomeSectionItem.worker(WorkerWorkplaceCellInfo(workplace: WorkplaceData(id: "1", name: "이마트24 수진점", category: "편의점", payType: "매월", payCalculation: "시급", salary: "10300", payDay: "3", nationalPension: true, healthInsurance: true, employmentInsurance: true, industrialAccidentInsurance: true, incomeTax: false, weeklyHolidayAllowance: true, nightShiftAllowance: false, colorLabel: "빨간색")))
    ])]

    // MARK: - Input, Output
    struct Input {
        var viewDidLoad: Observable<Void>
    }

    struct Output {
        var firstSectionData: Observable<[HomeTableViewFirstSection]>
    }

    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad.subscribe(onNext: { [weak self] in
            guard let self else { return }
            mockFirstSectionDataRelay.accept(mockFirstSectionData)
        })
        .disposed(by: disposeBag)

        return Output(
            firstSectionData: mockFirstSectionDataRelay.asObservable()
        )
    }

}
