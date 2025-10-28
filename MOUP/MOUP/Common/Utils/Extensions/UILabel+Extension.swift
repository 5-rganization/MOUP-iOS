//
//  UILabel+Extension.swift
//  MOUP
//
//  Created by 서동환 on 6/6/25.
//

import UIKit

extension UILabel {
    enum LineSpacing {
        case headBold
        case bodyMedium
        case fieldsRegular
        
        var ratio: Double {
            switch self {
            case .headBold:
                return 1.3
            case .bodyMedium:
                return 1.5
            case .fieldsRegular:
                return 1.5
            }
        }
    }
    
    func setLineSpacing(_ lineSpacing: LineSpacing) {
        let attributedString: NSMutableAttributedString
        
        if let currentAttributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: currentAttributedText)
        } else {
            guard let text = self.text, let font = self.font else { return }
            attributedString = NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: self.textColor ?? .gray900
                ]
            )
        }
        
        let style = NSMutableParagraphStyle()
        let lineheight = self.font.pointSize * lineSpacing.ratio // font size * ratio(Double)
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes([.paragraphStyle: style], range: fullRange)
        self.attributedText = attributedString
    }
}
