//
//  AttendanceMapper.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

struct AttendanceMapper {
    func mapToOwnerWorkplaceAttendanceHistory(dto: OwnerWorkplaceAttendanceHistoryDTO) -> OwnerWorkplaceAttendanceHistory {
        let attendanceInfoList = dto.workerWorkAttendanceInfoList.map { summary in
            let date = DateFormatter.yyyyMMdd.date(from: summary.workDate)
            let displayDate = date.map { DateFormatter.displayDate.string(from: $0) } ?? ""
            
            let start = DateFormatter.iso8601Full.date(from: summary.startTime)
            let actualStart = summary.actualStartTime.flatMap {
                DateFormatter.iso8601Full.date(from: $0)
            }
            let end = summary.endTime.flatMap { DateFormatter.iso8601Full.date(from: $0) }
            let actualEnd = summary.actualEndTime.flatMap {
                DateFormatter.iso8601Full.date(from: $0)
            }
            
            let displayStart = start.map { DateFormatter.displayTime.string(from: $0) } ?? ""
            let displayActualStart = actualStart.map { DateFormatter.displayTime.string(from: $0) }
            let displayEnd = end.map { DateFormatter.displayTime.string(from: $0) }
            let displayActualEnd = actualEnd.map { DateFormatter.displayTime.string(from: $0) }
            
            return AttendanceInfo(
                workId: summary.workId,
                workDate: displayDate,
                startTime: displayStart,
                actualStartTime: displayActualStart,
                endTime: displayEnd,
                actualEndTime: displayActualEnd
            )
        }
        
        return OwnerWorkplaceAttendanceHistory(
            workplaceId: dto.workplaceId,
            workerId: dto.workerId,
            workerWorkAttendanceInfoList: attendanceInfoList
        )
    }
    
    func mapToWorkerWorkplaceAttendanceHistory(dto: WorkerWorkplaceAttendanceHistoryDTO) -> WorkerWorkplaceAttendanceHistory {
        let attendanceInfoList = dto.myWorkAttendanceInfoList.map { summary in
            let date = DateFormatter.yyyyMMdd.date(from: summary.workDate)
            let displayDate = date.map { DateFormatter.displayDate.string(from: $0) } ?? ""
            
            let start = DateFormatter.iso8601Full.date(from: summary.startTime)
            let actualStart = summary.actualStartTime.flatMap {
                DateFormatter.iso8601Full.date(from: $0)
            }
            let end = summary.endTime.flatMap { DateFormatter.iso8601Full.date(from: $0) }
            let actualEnd = summary.actualEndTime.flatMap {
                DateFormatter.iso8601Full.date(from: $0)
            }
            
            let displayStart = start.map { DateFormatter.displayTime.string(from: $0) } ?? ""
            let displayActualStart = actualStart.map { DateFormatter.displayTime.string(from: $0) }
            let displayEnd = end.map { DateFormatter.displayTime.string(from: $0) }
            let displayActualEnd = actualEnd.map { DateFormatter.displayTime.string(from: $0) }
            
            return AttendanceInfo(
                workId: summary.workId,
                workDate: displayDate,
                startTime: displayStart,
                actualStartTime: displayActualStart,
                endTime: displayEnd,
                actualEndTime: displayActualEnd
            )
        }
        return WorkerWorkplaceAttendanceHistory(myWorkAttendanceInfoList: attendanceInfoList)
    }
}
