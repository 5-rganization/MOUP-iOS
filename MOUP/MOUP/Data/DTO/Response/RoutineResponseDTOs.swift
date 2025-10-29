//
//  RoutineResponseDTOs.swift
//  MOUP
//
//  Created by 서동환 on 10/29/25.
//

struct RoutineSummaryResponseDTO: Decodable {
    let routineId: Int
    let routineName: String
    let alarmTime: String?
}

struct RoutineSummaryListResponseDTO: Decodable {
    let routineSummaryInfoList: [RoutineSummaryResponseDTO]
}
