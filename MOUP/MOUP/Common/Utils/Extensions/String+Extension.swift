//
//  String+Extension.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//

import UIKit

extension String {
    func toUIColor() -> UIColor {
        switch self {
        case "빨강색": return .labelRed
        case "주황색": return .labelOrange
        case "노란색": return .labelYellow
        case "초록색": return .labelGreen
        case "파란색": return .labelBlue
        case "보라색": return .labelPurple
        case "남색": return .indigoText
        default: return .clear
        }
    }
}
