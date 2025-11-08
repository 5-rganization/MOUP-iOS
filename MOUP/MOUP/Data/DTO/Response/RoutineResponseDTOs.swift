//
//  RoutineResponseDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import Foundation

struct TodayRoutineResponseDTO: Decodable {
    let todayWorkRoutineCountList: [TodayWorkRoutineCountDTO]
}

struct TodayWorkRoutineCountDTO: Decodable {
    let workId: Int
    let workplaceSummaryInfo: WorkplaceSummaryInfoDTO
    let startTime: String
    let endTime: String
    let workMinutes: Int
    let routineCount: Int
}

/// 근무 ID에 해당하는 루틴
struct WorkRoutineResponseDTO: Decodable {
    let routineSummaryInfoList: [RoutineSummaryDTO]
}

struct AllRoutineResponseDTO: Decodable {
    let routineSummaryInfoList: [RoutineSummaryDTO]
}

/// 루틴 요약 정보 리스트 응답 DTO
struct RoutineSummaryListResponseDTO: Decodable {
    let routineSummaryInfoList: [RoutineSummaryDTO]
}

struct RoutineSummaryDTO: Decodable {
    let routineId: Int
    let routineName: String
    let alarmTime: String?
}

/// 루틴 생성 응답 DTO
struct CreateRoutineResponseDTO: Decodable {
    let routineId: Int
}

/// 루틴 상세 조회 응답 DTO
struct RoutineDetailResponseDTO: Decodable {
    let routineId: Int
    let routineName: String
    let alarmTime: String?
    let routineTaskList: [RoutineTaskDetailDTO]
}

struct RoutineTaskDetailDTO: Decodable {
    let content: String
    let orderIndex: Int
}

extension RoutineDetailResponseDTO {
    func toDomain() -> RoutineDetail {
        RoutineDetail(
            routineId: routineId,
            routineName: routineName,
            alarmTime: alarmTime,
            tasks: routineTaskList.map { task in
                RoutineTaskItem(
                    content: task.content,
                    orderIndex: task.orderIndex
                )
            }
        )
    }
}
