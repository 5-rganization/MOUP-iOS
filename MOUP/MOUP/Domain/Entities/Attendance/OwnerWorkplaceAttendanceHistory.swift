//
//  OwnerWorkplaceAttendanceHistory.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

struct OwnerWorkplaceAttendanceHistory {
    let workplaceId: Int
    let workerId: Int
    let workerWorkAttendanceInfoList: [AttendanceInfo]
}
