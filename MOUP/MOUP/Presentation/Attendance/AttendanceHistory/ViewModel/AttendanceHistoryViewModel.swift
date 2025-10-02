//
//  ManageAttendanceViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 9/24/25.
//

import Foundation
import RxSwift
import RxRelay

final class AttendanceHistoryViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let mockAttendanceData = [
        AttendanceItem(items: [
            AttendanceData(date: "7/8 월", attendanceTime: "09 : 00", leaveWorkTime: "09 : 00"),
            AttendanceData(date: "7/9 화", attendanceTime: "12 : 00", leaveWorkTime: "15 : 00"),
            AttendanceData(date: "7/10 수", attendanceTime: "09 : 00", leaveWorkTime: "12 : 00")
        ])
    ]
    private lazy var attendanceDataRelay = BehaviorRelay<[AttendanceItem]>(value: mockAttendanceData)
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let attendanceData: Observable<[AttendanceItem]>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        
        return Output(
            attendanceData: attendanceDataRelay.asObservable()
        )
    }
        
}
