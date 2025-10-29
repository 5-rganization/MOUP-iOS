//
//  RoutineResponseDTOs.swift
//  MOUP
//
//  Created by 서동환 on 10/29/25.
//

/// 루틴 요약 정보 응답 DTO
struct RoutineSummaryResponseDTO: Decodable {
    let routineId: Int
    let routineName: String
    let alarmTime: String?
}

/// 루틴 요약 정보 리스트 응답 DTO
struct RoutineSummaryListResponseDTO: Decodable {
    let routineSummaryInfoList: [RoutineSummaryResponseDTO]
}
