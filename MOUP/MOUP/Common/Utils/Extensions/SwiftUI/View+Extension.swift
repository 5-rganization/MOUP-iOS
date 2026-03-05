//
//  View+Extension.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

extension View {
    func setLineSpacing(_ spacing: UILabel.LineSpacing, fontSize: CGFloat) -> some View {
        let targetLineHeight = fontSize * spacing.ratio
        
        let uiFont = UIFont(name: "Pretendard-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
        let defaultLineHeight = uiFont.lineHeight
        
        let extraSpacing = targetLineHeight - defaultLineHeight
        
        return self.lineSpacing(max(0, extraSpacing))
    }
}
