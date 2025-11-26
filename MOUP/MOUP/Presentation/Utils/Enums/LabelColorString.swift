//
//  LabelColorString.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

import UIKit

enum LabelColorString: String, CaseIterable {
    case _default = "DEFAULT"
    case red = "RED"
    case orange = "ORANGE"
    case yellow = "YELLOW"
    case green = "GREEN"
    case blue = "BLUE"
    case indigo = "INDIGO"
    case purple = "PURPLE"
    
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
    
    // MARK: - Initializer by displayStr
    init(displayStr: String) {
        if let matchedCase = LabelColorString.allCases.first(where: { $0.displayStr == displayStr }) {
            self = matchedCase
        } else {
            assertionFailure("displayStr에 맞는 case를 찾을 수 없습니다.")
            self = ._default
        }
    }
}

