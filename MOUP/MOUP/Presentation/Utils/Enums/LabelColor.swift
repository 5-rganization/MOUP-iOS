//
//  LabelColor.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

enum LabelColor: CaseIterable {
    case _default
    case red
    case orange
    case yellow
    case green
    case blue
    case indigo
    case purple
    
    var serverStr: String {
        switch self {
        case ._default:
            return "DEFAULT"
        case .red:
            return "RED"
        case .orange:
            return "ORANGE"
        case .yellow:
            return "YELLOW"
        case .green:
            return "GREEN"
        case .blue:
            return "BLUE"
        case .indigo:
            return "INDIGO"
        case .purple:
            return "PURPLE"
        }
    }
    
    var displayStr: String {
        switch self {
        case ._default:
            "기본색"
        case .red:
            "빨간색"
        case .orange:
            "주황색"
        case .yellow:
            "노란색"
        case .green:
            "초록색"
        case .blue:
            "파란색"
        case .indigo:
            "남색"
        case .purple:
            "보라색"
        }
    }
    
    var labelColor: UIColor {
        switch self {
        case ._default:
            return .primary500
        case .red:
            return .labelRed
        case .orange:
            return .labelOrange
        case .yellow:
            return .labelYellow
        case .green:
            return .labelGreen
        case .blue:
            return .labelBlue
        case .indigo:
            return .labelIndigo
        case .purple:
            return .labelPurple
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case ._default:
            return .primary100
        case .red:
            return .redBackground
        case .orange:
            return .orangeBackground
        case .yellow:
            return .yellowBackground
        case .green:
            return .greenBackground
        case .blue:
            return .blueBackground
        case .indigo:
            return .indigoBackground
        case .purple:
            return .purpleBackground
        }
    }
    
    var textColor: UIColor {
        switch self {
        case ._default:
            return .primary600
        case .red:
            return .redText
        case .orange:
            return .orangeText
        case .yellow:
            return .yellowText
        case .green:
            return .greenText
        case .blue:
            return .blueText
        case .indigo:
            return .indigoText
        case .purple:
            return .purpleText
        }
    }
    
    init?(serverStr: String) {
        if let matchedCase = LabelColor.allCases.first(where: { $0.serverStr == serverStr }) {
            self = matchedCase
        } else {
            return nil
        }
    }
    
    init?(displayStr: String) {
        if let matchedCase = LabelColor.allCases.first(where: { $0.displayStr == displayStr }) {
            self = matchedCase
        } else {
            return nil
        }
    }
}

