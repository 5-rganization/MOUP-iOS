//
//  WorkerLabelColor.swift
//  MOUP
//
//  Created by 양원식 on 11/17/25.
//

enum WorkerLabelColor {
    case red
    case orange       
    case yellow
    case green
    case blue
    case navy
    case purple
    
    // MARK: - Display Text (UI)
    var displayText: String {
        switch self {
        case .red:    return "빨강색"
        case .orange: return "주황색"
        case .yellow: return "노란색"
        case .green:  return "초록색"
        case .blue:   return "파란색"
        case .navy:   return "남색"
        case .purple: return "보라색"
        }
    }
    
    // MARK: - Server ENUM
    var serverValue: String {
        switch self {
        case .red:    return "RED"
        case .orange: return "ORANGE"
        case .yellow: return "YELLOW"
        case .green:  return "GREEN"
        case .blue:   return "BLUE"
        case .navy:   return "NAVY"
        case .purple: return "PURPLE"
        }
    }
    
    // MARK: - UI → ENUM
    init?(displayText: String) {
        switch displayText {
        case "빨강색": self = .red
        case "주황색": self = .orange
        case "노란색": self = .yellow
        case "초록색": self = .green
        case "파란색": self = .blue
        case "남색":   self = .navy
        case "보라색": self = .purple
        default: return nil
        }
    }
    
    // MARK: - Server → ENUM
    init?(serverValue: String) {
        switch serverValue {
        case "RED":    self = .red
        case "ORANGE": self = .orange
        case "YELLOW": self = .yellow
        case "GREEN":  self = .green
        case "BLUE":   self = .blue
        case "NAVY":   self = .navy
        case "PURPLE": self = .purple
        default: return nil
        }
    }
}
