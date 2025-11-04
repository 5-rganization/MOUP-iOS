//
//  AttendanceData.swift
//  MOUP
//
//  Created by 송규섭 on 9/25/25.
//

import Foundation

/// 날짜 - m/d 요일 형식의 근무 날짜를 말합니다
/// 출근, 퇴근 - hh:mm 형식의 출·퇴근 시간을 말합니다.
struct AttendanceData {
    let date: String
    let attendanceTime: String
    let leaveWorkTime: String
}
