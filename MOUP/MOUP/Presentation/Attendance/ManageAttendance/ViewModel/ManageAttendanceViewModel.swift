//
//  ManageAttendanceViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import Foundation
import RxSwift
import RxRelay

final class ManageAttendanceViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let mockEmployees = [
        ManageAttendanceItem(items: [
            Employee(name: "송알바", labelColor: "빨간색"),
            Employee(name: "김알바", labelColor: "주황색"),
            Employee(name: "제시카알바", labelColor: "남색"),
            Employee(name: "아알바", labelColor: "파란색")
        ])
    ]
    private lazy var employeesRelay = BehaviorRelay<[ManageAttendanceItem]>(value: mockEmployees)
    
    // MARK: - Initializer
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let employees: Observable<[ManageAttendanceItem]>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        
        return Output(employees: employeesRelay.asObservable())
    }
    
}
