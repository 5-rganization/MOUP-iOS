//
//  WorkTime.swift
//  MOUP
//
//  Created by 양원식 on 8/13/25.
//

import Foundation

enum TimePeriod: Int, CaseIterable {
    case am = 0
    case pm = 1
    
    var title: String { self == .am ? "오전" : "오후" }
}

struct WorkTime {
    var period: TimePeriod
    var hour: Int     // 1...12
    var minute: Int   // 0...59 (보통 5분 단위)

    var hour24: Int {
        let base = hour % 12
        switch period {
        case .am: return hour == 12 ? 0 : base
        case .pm: return hour == 12 ? 12 : base + 12
        }
    }
    
    var formatted: String {
        String(format: "%@ %d:%02d", period.title, hour, minute)
    }
}
